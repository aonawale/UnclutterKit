import CoreData

extension TableChange {

    init?(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else {
                return nil
            }
            self = .delete(at: indexPath)

        case .insert:
            guard let indexPath = newIndexPath else {
                return nil
            }
            self = .insert(at: indexPath)

        case .move:
            guard
                let source = indexPath,
                let destination = newIndexPath else {
                    return nil
            }
            self = .move(from: source, to: destination)

        case .update:
            guard let indexPath = indexPath else {
                return nil
            }
            self = .update(at: indexPath)
        }
    }

    init?(type: NSFetchedResultsChangeType, atSectionIndex sectionIndex: Int) {
        switch type {
        case .delete:
            self = .deleteSection(atSectionIndex: sectionIndex)
        case .insert:
            self = .insertSection(atSectionIndex: sectionIndex)
        default:
            return nil
        }
    }
}
