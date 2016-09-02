import CoreData

public enum TableChange {

	// row
	case delete(at: IndexPath)
	case insert(at: IndexPath)
	case move(from: IndexPath, to: IndexPath)
	case update(at: IndexPath)

	// section
	case insertSection(atSectionIndex: Int)
	case deleteSection(atSectionIndex: Int)
}

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

extension TableChange: Equatable {}

public func == (left: TableChange, right: TableChange) -> Bool {
	switch (left, right) {
	case (.insertSection(let leftSection), .insertSection(let rightSection))
		where leftSection == rightSection:
		return true
	case (.deleteSection(let leftSection), .deleteSection(let rightSection))
		where leftSection == rightSection:
		return true
	case (.insert(let leftIndexPath), .insert(let rightIndexPath))
		where leftIndexPath == rightIndexPath:
		return true
	case (.update(let leftIndexPath), .update(let rightIndexPath))
		where leftIndexPath == rightIndexPath:
		return true
	case (.delete(let leftIndexPath), .delete(let rightIndexPath))
		where leftIndexPath == rightIndexPath:
		return true
	case (.move(let leftIndexPath1, let leftIndexPath2),
	      .move(let rightIndexPath1, let rightIndexPath2))
		where leftIndexPath1 == rightIndexPath1 && leftIndexPath2 == rightIndexPath2:
		return true
	default:
		return false
	}
}

extension TableChange: Comparable {}

public func < (left: TableChange, right: TableChange) -> Bool {
	switch (left, right) {

	// Delete Section
	case (.deleteSection(let leftSection), .deleteSection(let rightSection)):
		return leftSection < rightSection
	case (.deleteSection, _):
		return true

	// Insert Section
	case (.insertSection(let leftSection), .insertSection(let rightSection)):
		return leftSection < rightSection
	case (.insertSection, .deleteSection):
		return false
	case (.insertSection, _):
		return true

	// Move
	case (.move(let leftFromIndexPath, let leftToIndexPath),
	      .move(let rightFromIndexPath, let rightToIndexPath)):
		if leftFromIndexPath == rightFromIndexPath {
			return leftToIndexPath < rightToIndexPath
		}
		return leftFromIndexPath < rightFromIndexPath
	case (.move, .deleteSection): fallthrough
	case (.move, .insertSection):
		return false
	case (.move, _):
		return true

	// Delete
	case (.delete(let leftIndexPath), .delete(let rightIndexPath)):
		return leftIndexPath < rightIndexPath
	case (.delete, .deleteSection): fallthrough
	case (.delete, .deleteSection): fallthrough
	case (.delete, .move):
		return false
	case (.delete, _):
		return true

	// Insert
	case (.insert(let leftIndexPath), .insert(let rightIndexPath)):
		return leftIndexPath < rightIndexPath
	case (.insert, .deleteSection): fallthrough
	case (.insert, .deleteSection): fallthrough
	case (.insert, .move): fallthrough
	case (.insert, .delete):
		return false
	case (.insert, .update):
		return true

	// Update
	case (.update(let leftIndexPath), .update(let rightIndexPath)):
		return leftIndexPath < rightIndexPath
	default:
		return false
	}
}

func adjust(_ indexPath: IndexPath, basedOn changes: [TableChange]) -> IndexPath {
	var section = indexPath.section
	var row = indexPath.row

	for change in changes.sorted() {
		switch change {
		case .deleteSection(let deletedSection) where deletedSection <= section:
			section -= 1
		case .insertSection(let insertedSection) where insertedSection <= section:
			section += 1
		case .delete(let deletedIndexPath)
			where deletedIndexPath.section == section && deletedIndexPath.row <= row:
			row -= 1
		case .insert(let insertedIndexPath)
			where insertedIndexPath.section == section && insertedIndexPath.row <= row:
			row += 1
		case .move(let fromIndexPath, let toIndexPath):
			if fromIndexPath.section == section && fromIndexPath.row <= row {
				row -= 1
			}
			if toIndexPath.section == section && toIndexPath.row <= row {
				row += 1
			}
		default: ()
		}
	}

	return IndexPath(row: row, section: section)
}
