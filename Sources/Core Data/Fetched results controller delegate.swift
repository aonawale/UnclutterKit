import CoreData
import UIKit

protocol TableUpdatable {

	func beginUpdates()
	func endUpdates()

	func apply(_ tableChange: TableChange)
}

extension UICollectionView: BatchUpdatable {

	func performBatchUpdates(_ updates: () -> Void) {
		performBatchUpdates(updates, completion: nil)
	}

	func apply(_ tableChange: TableChange) {
		switch tableChange {
		case .delete(let indexPath):
			deleteItems(at: [indexPath])
		case .insert(let indexPath):
			insertItems(at: [indexPath])
		case .move(let source, let destination):
			moveItem(at: source, to: destination)
		case .update(let indexPath):
			reloadItems(at: [indexPath])
		case .deleteSection(let sectionIndex):
			deleteSections([sectionIndex])
		case .insertSection(let sectionIndex):
			insertSections([sectionIndex])
		}
	}
}

protocol BatchUpdatable {
	func apply(_ tableChange: TableChange)
	func performBatchUpdates(_: () -> Void)
}

extension UITableView: BatchUpdatable {

	func apply(_ tableChange: TableChange) {
		switch tableChange {
		case .delete(let indexPath):
			deleteRows(at: [indexPath], with: .automatic)
		case .insert(let indexPath):
			insertRows(at: [indexPath], with: .automatic)
		case .move(let source, let destination):
			moveRow(at: source, to: destination)
		case .update(let indexPath):
			reloadRows(at: [indexPath], with: .fade)
		case .deleteSection(let sectionIndex):
			deleteSections([sectionIndex], with: .automatic)
		case .insertSection(let sectionIndex):
			insertSections([sectionIndex], with: .automatic)
		}
	}

	func performBatchUpdates(_ updates: () -> Void) {
		beginUpdates()
		updates()
		endUpdates()
	}
}

class TableUpdater: TableUpdatable {

	let batchUpdater: BatchUpdatable

	init(_ batchUpdater: BatchUpdatable) {
		self.batchUpdater = batchUpdater
	}

	private var changes: [TableChange] = []

	func apply(_ tableChange: TableChange) {
		changes.append(tableChange)
	}

	func beginUpdates() {
		changes = []
	}

	func endUpdates() {
		let (updates, other) = extractCorrectedUpdates(in: self.changes)

		if other.count > 0 {
			batchUpdater.performBatchUpdates({
				other.forEach(self.batchUpdater.apply)
			})
		}
		if updates.count > 0 {
			batchUpdater.performBatchUpdates({
				updates.forEach(self.batchUpdater.apply)
			})
		}
	}
}

func extractCorrectedUpdates(
	in changes: [TableChange]) -> (updates: [TableChange], other: [TableChange]) {

	let updateIndexPaths = changes
		.flatMap { change -> IndexPath? in
			if case .update(let indexPath) = change {
				return indexPath
			}
			return nil
	}

	let nonUpdateChanges = changes.filter {
		if case .update = $0 {
			return false
		}
		return true
	}

	let updates = updateIndexPaths
		.map { TableChange.update(at: adjust($0, basedOn: nonUpdateChanges)) }

	return (updates: updates,
	        other: nonUpdateChanges)
}

class FetchedResultsControllerDelegate<Model: NSFetchRequestResult>: NSObject,
NSFetchedResultsControllerDelegate {

	init(tableUpdater: TableUpdatable) {
		self.tableUpdater = tableUpdater
	}

	private let tableUpdater: TableUpdatable

	func controllerDidChangeContent(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableUpdater.endUpdates()
	}

	func controllerWillChangeContent(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableUpdater.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
	                didChange anObject: AnyObject,
	                at indexPath: IndexPath?,
	                for type: NSFetchedResultsChangeType,
	                newIndexPath: IndexPath?) {
		if let tableChange = TableChange(type: type, indexPath: indexPath, newIndexPath: newIndexPath) {
			tableUpdater.apply(tableChange)
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
	                didChange sectionInfo: NSFetchedResultsSectionInfo,
	                atSectionIndex sectionIndex: Int,
	                for type: NSFetchedResultsChangeType) {
		if let tableChange = TableChange(type: type, atSectionIndex: sectionIndex) {
			tableUpdater.apply(tableChange)
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
	                sectionIndexTitleForSectionName sectionName: String) -> String? {
		return sectionName
	}
}
