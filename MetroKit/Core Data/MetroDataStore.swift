import Combine
import CoreData

/// An interface to get and update the user's Metro Card.
public protocol MetroCardDataStore {
    /// Returns the user's current Metro Card, or creates one if needed.
    func currentCard() throws -> ObjectReference<MetroCard>
    
    /// A publisher that emits the current card and subsequent updates to it.
    func publisher(for card: ObjectReference<MetroCard>) -> AnyPublisher<ObjectReference<MetroCard>, Never>
    
    /// Update the data on the specified card reference by using the given update descriptior.
    func applyUpdates(_ update: [MetroCardUpdate],
                      to cardReference: ObjectReference<MetroCard>) -> AnyPublisher<Void, Error>
}

/// A concrete Metro card Data store that uses Core Data as a storage mechanism.
public class PersistentMetroCardDataStore: MetroCardDataStore {
    let container: NSPersistentContainer
    let saveContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    /// Creates a persistent data store using the specified options.
    /// - parameter persistentStore: The type of persistent store to use.
    /// - parameter useCloudKit: Whether to use automatic CloudKit syncing.
    /// - throws: Any error thrown while resolving the persistent store. See `PersistentStore` for the possible errors.
    public init(persistentStore: PersistentStore, useCloudKit: Bool) throws {
        if useCloudKit {
            container = NSPersistentCloudKitContainer(name: "Metro", managedObjectModel: .metroModels)
        } else {
            container = NSPersistentContainer(name: "Metro", managedObjectModel: .metroModels)
        }
        
        container.persistentStoreDescriptions = [
            try persistentStore.makePersistentStoreDescriptor(in: .default, name: "Metro")
        ]
        
        try container.loadPersistentStoresAndWait()
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.retainsRegisteredObjects = true
    
        saveContext = container.newBackgroundContext()
    }
    
    // MARK: - Get Card
    
    public func currentCard() throws -> ObjectReference<MetroCard> {
        try getOrCreateCard()
            .map { $0.makeReferenceSnapshot() }
            .get()
    }
    
    public func publisher(for card: ObjectReference<MetroCard>) -> AnyPublisher<ObjectReference<MetroCard>, Never> {
        let card = container.viewContext.object(with: card.objectID) as! MBYMetroCard
        return ManagedObjectContextObserver(context: container.viewContext, object: card)
            .map { $0.makeReferenceSnapshot() }
            .removeDuplicates { $0.snapshot == $1.snapshot }
            .eraseToAnyPublisher()
    }
    
    private func getOrCreateCard() -> Result<MBYMetroCard, MetroCardDataStoreError> {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<MBYMetroCard>(entityName: "MetroCard")
        do {
            if let existingCard = try context.fetch(fetchRequest).first {
                return .success(existingCard)
            } else {
                return createFirstCard()
            }
        } catch {
            return .failure(.cannotRead(error as NSError))
        }
    }
    
    private func createFirstCard() -> Result<MBYMetroCard, MetroCardDataStoreError> {
        var result: Result<MBYMetroCard, MetroCardDataStoreError>!
        saveContext.performAndWait { [saveContext] in
            do {
                let newCard = MBYMetroCard(context: saveContext)
                newCard.populateFields(with: MetroCard.makeDefault())
                try saveContext.save()
                try saveContext.obtainPermanentIDs(for: [newCard])
                let convertedCard = container.viewContext.object(with: newCard.objectID) as! MBYMetroCard
                result = .success(convertedCard)
            } catch {
                result = .failure(.cannotSave(error as NSError))
            }
        }
        return result
    }
    
    // MARK: - Update Card
    
    public func applyUpdates(
        _ updates: [MetroCardUpdate],
        to cardReference: ObjectReference<MetroCard>
    ) -> AnyPublisher<Void, Error> {
        let completionSubject = PassthroughSubject<Void, Error>()
        saveContext.performAndWait { [saveContext] in
            do {
                guard let card = try saveContext.existingObject(with: cardReference.objectID) as? MBYMetroCard else {
                    return completionSubject.send(completion: .failure(MetroCardDataStoreError.cardNotFound))
                }
                
                for update in updates {
                    switch update {
                    case .balance(let newValue):
                        card.balance = newValue as NSDecimalNumber
                    case .expirationDate(let newValue):
                        card.expirationDate = newValue
                    case .serialNumber(let newValue):
                        card.serialNumber = newValue
                    case .fare(let newValue):
                        card.fare = newValue as NSDecimalNumber
                    }
                }

                try saveContext.save()
                completionSubject.send(())
                completionSubject.send(completion: .finished)
            } catch {
                completionSubject.send(completion: .failure(MetroCardDataStoreError.cannotSave(error as NSError)))
            }
        }
        return completionSubject
            .eraseToAnyPublisher()
    }
}