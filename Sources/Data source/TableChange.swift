//import CoreData
import Foundation

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

// swiftlint:disable cyclomatic_complexity function_body_length
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
