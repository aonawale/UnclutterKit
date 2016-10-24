import CoreData
import UIKit

public protocol TableUpdatable {
	func apply(_ tableChange: TableChange)
	func beginUpdates()
	func endUpdates()
}

public protocol BatchUpdatable {
	func apply(_ changes: [TableChange])
}

extension UICollectionView: BatchUpdatable {

	private func apply(_ tableChange: TableChange) {
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

	public func apply(_ changes: [TableChange]) {
		performBatchUpdates({ changes.forEach(self.apply) }, completion: nil)
	}
}

extension UITableView: BatchUpdatable {

	private func apply(_ tableChange: TableChange) {
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

	public func apply(_ changes: [TableChange]) {
		beginUpdates()
		changes.forEach(apply)
		endUpdates()
	}
}

public class TableUpdater: TableUpdatable {

	let batchUpdater: BatchUpdatable

	public init(_ batchUpdater: BatchUpdatable) {
		self.batchUpdater = batchUpdater
	}

	private var changes: [TableChange] = []

	public func apply(_ tableChange: TableChange) {
		changes.append(tableChange)
	}

	public func beginUpdates() {
		changes = []
	}

	public func endUpdates() {
		let (nonUpdates, updates) = changes.corrected()
		batchUpdater.apply(nonUpdates)
		batchUpdater.apply(updates)
	}
}

extension Sequence where Self.Iterator.Element == TableChange {

	func corrected() -> (nonUpdates: [TableChange], updates: [TableChange]) {
		let nonUpdates = filter {
			if case .update = $0 {
				return false
			}
			return true
		}

		let updates: [TableChange] = flatMap {
			if case .update(let indexPath) = $0 {
				return TableChange.update(at: indexPath.adjusted(basedOn: nonUpdates))
			}
			return nil
		}

		return (nonUpdates, updates)
	}
}

extension IndexPath {

	func adjusted(basedOn changes: [TableChange]) -> IndexPath {
		var newRow = self.row
		var newSection = self.section

		for change in changes.sorted() {
			switch change {
			case .deleteSection(let deletedSection) where deletedSection <= newSection:
				newSection -= 1
			case .insertSection(let insertedSection) where insertedSection <= newSection:
				newSection += 1
			case .delete(let deletedIndexPath)
				where deletedIndexPath.section == newSection && deletedIndexPath.row <= newRow:
				newRow -= 1
			case .insert(let insertedIndexPath)
				where insertedIndexPath.section == newSection && insertedIndexPath.row <= newRow:
				newRow += 1
			case .move(let fromIndexPath, let toIndexPath):
				if fromIndexPath.section == newSection && fromIndexPath.row <= newRow {
					newRow -= 1
				}
				if toIndexPath.section == newSection && toIndexPath.row <= newRow {
					newRow += 1
				}
			default: ()
			}
		}

		return IndexPath(row: newRow, section: newSection)
	}
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
	                didChange anObject: Any,
	                at indexPath: IndexPath?,
	                for type: NSFetchedResultsChangeType,
	                newIndexPath: IndexPath?) {
		if let tableChange = TableChange(type: type,
		                                 indexPath: indexPath,
		                                 newIndexPath: newIndexPath) {
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
