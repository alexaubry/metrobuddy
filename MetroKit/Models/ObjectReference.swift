import CoreData

/// Represents a reference to a managed object.
///
/// This class encapsulates the internal ID of the managed object and provides a reference to a derived object, usually a `struct`
/// with constant fields initialized from the managed object during fetch.
///
/// Using this class enables the data store to access the object by ID when editing it, while hiding the actual instance of the `NSManagedObject`.
/// You can access the snapshot's data through the `object` property, or directly from the reference, since it supports dynamic member lookup.
@dynamicMemberLookup
public struct ObjectReference<Snapshot> {
    let objectID: NSManagedObjectID
    
    /// The snapshot of the object that is being referenced.
    public let snapshot: Snapshot
    
    /// Returns the value at the specified key path from the referenced object.
    public subscript<Value>(dynamicMember keyPath: KeyPath<Snapshot, Value>) -> Value {
        return snapshot[keyPath: keyPath]
    }
}
