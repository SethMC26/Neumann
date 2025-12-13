/*
 *   Copyright (C) 2025  Seth Holtzman
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

///This file holds miscalleounus enums and structs that are small and uncomplex for use in Model. 

///Errors that can be thrown by our app
enum AppError: Error {
    case noLoadedDataset
    case notEnoughColumns
    case headerNotRecongized
    case internalStateError
    case minGreaterThanMax
}


/// Axis with x y and z
enum Axis {
    case x
    case y
    case z
}

/// Row of data for use in Chart3D
struct Row : Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let z: Double
    let category: String?
}
