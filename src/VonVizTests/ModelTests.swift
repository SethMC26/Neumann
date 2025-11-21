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

/**
 Unit tests for the application model layer (`/Model`).

 These tests cover `DataChartModel`, `AxisInfo`, `FuncChartModel`, and
 related behaviors (CSV ingestion, axis mapping, domain handling, and
 NaN/row-skipping logic).

 Author: GitHub Copilot (AI assistant)
 */
import Foundation
import Testing
@testable import VonViz

struct ModelTests {

    enum TestFailure: Error {
        case fail(String)
    }

    private func ensure(_ cond: Bool, _ msg: String) throws {
        if !cond { throw TestFailure.fail(msg) }
    }

    @Test func axisinfo_domain_and_defaults() async throws {
        let ai = AxisInfo()
        let domain = ai.getDomain()
        try ensure(domain.lowerBound == -50 && domain.upperBound == 50, "Expected default domain -50...50 but got \(domain)")
    }

    @Test func datamodel_render_without_dataset_throws() async throws {
        let model = DataChartModel()
        do {
            try model.render()
            throw TestFailure.fail("Expected render() to throw when no dataset loaded")
        } catch let e as AppError {
            try ensure(e == .noLoadedDataset, "Expected noLoadedDataset but got \(e)")
        }
    }

    func writeTempCSV(_ contents: String) throws -> URL {
        let tmp = FileManager.default.temporaryDirectory
        let url = tmp.appendingPathComponent("test_\(UUID().uuidString).csv")
        try contents.data(using: .utf8)!.write(to: url)
        return url
    }

    @Test func ingest_and_render_and_axis_ranges() async throws {
        let csv = "xcol,ycol,zcol,name\n1,2,3,foo\n4,5,6,bar\n7,8,9,baz\n"
        let file = try writeTempCSV(csv)

        let model = DataChartModel()
        try model.ingestFile(file: file)

        try ensure(model.headers.count >= 3, "Expected at least 3 headers after ingest")
        try ensure(model.getAxisHeader(axisToGet: .x) != nil, "Expected x axis header to be set")

        let rows = model.rows
        try ensure(rows.count == 3, "Expected 3 rows after render but got \(rows.count)")

        let rangeX = try model.getAxisRange(axis: .x)
        try ensure(rangeX.lowerBound == 1.0 && rangeX.upperBound == 7.0, "Expected x range 1...7 but got \(rangeX)")

        // set x axis to zcol and ensure rows x values come from zcol
        try model.setAxis(axisToSet: .x, header: "zcol")
        try ensure(model.getAxisHeader(axisToGet: .x) == "zcol", "Expected x header to be zcol after setAxis")
        try ensure(model.rows.first?.x == 3.0, "Expected first row.x == 3 after remapping x to zcol but got \(String(describing: model.rows.first?.x))")
    }

    @Test func ingest_not_enough_columns_throws() async throws {
        let csv = "a,b\n1,2\n3,4\n"
        let file = try writeTempCSV(csv)

        let model = DataChartModel()
        do {
            try model.ingestFile(file: file)
            throw TestFailure.fail("Expected ingestFile to throw notEnoughColumns for <3 numeric cols")
        } catch let e as AppError {
            try ensure(e == .notEnoughColumns, "Expected notEnoughColumns but got \(e)")
        }
    }

    @Test func set_axis_domain_validation() async throws {
        let csv = "xcol,ycol,zcol\n1,2,3\n4,5,6\n7,8,9\n"
        let file = try writeTempCSV(csv)
        let model = DataChartModel()
        try model.ingestFile(file: file)

        // set invalid domain min > max
        do {
            try model.setAxisDomain(axis: .x, min: 10, max: 0, steps: nil)
            throw TestFailure.fail("Expected setAxisDomain to throw minGreaterThanMax when min>max")
        } catch let e as AppError {
            try ensure(e == .minGreaterThanMax, "Expected minGreaterThanMax but got \(e)")
        }

        // set valid domain and verify getAxisRange follows new domain
        try model.setAxisDomain(axis: .x, min: 0, max: 100, steps: 5)
        let r = try model.getAxisRange(axis: .x)
        try ensure(r.lowerBound == 0 && r.upperBound == 100, "Expected axis domain 0...100 but got \(r)")
    }

    @Test func ingest_skips_nan_rows() async throws {
        // third row missing zcol so should be skipped
        let csv = "xcol,ycol,zcol\n1,2,3\n4,5,\n7,8,9\n"
        let file = try writeTempCSV(csv)
        let model = DataChartModel()
        try model.ingestFile(file: file)

        // there are 3 input rows but middle row has NaN -> expect 2 rows after render
        try ensure(model.rows.count == 2, "Expected 2 rows after skipping NaN but got \(model.rows.count)")
    }

    @Test func funcchartmodel_parses_and_evaluates_ast() async throws {
        let fm = try FuncChartModel(input: "x+1")
        let val = try fm.ast.eval(2.0, 0.0)
        try ensure(val == 3.0, "Expected x+1 with x=2 to equal 3 but got \(val)")
    }

    @Test func get_axis_info_returns_struct() async throws {
        let model = DataChartModel()
        let ai = try model.getAxisInfo(axis: .x)
        try ensure(ai.header == "X Axis" && ai.min == -50 && ai.max == 50, "Expected default AxisInfo values")
    }
    
    // MARK: - FuncChartModel tests (new)

    @Test func funcchartmodel_defaults_and_domains() async throws {
        let fm = try FuncChartModel(input: "x")
        // Defaults
        try ensure(fm.xAxis.header == "x" && fm.yAxis.header == "y" && fm.zAxis.header == "z",
                   "Axis headers should default to x/y/z")
        try ensure(fm.xAxis.min == -5 && fm.xAxis.max == 5 && fm.xAxis.steps == 1,
                   "X defaults should be -5...5 step 1")
        try ensure(fm.yAxis.min == -5 && fm.yAxis.max == 5 && fm.yAxis.steps == 1,
                   "Y defaults should be -5...5 step 1")
        try ensure(fm.zAxis.min == -5 && fm.zAxis.max == 5 && fm.zAxis.steps == 1,
                   "Z defaults should be -5...5 step 1")
    }

    @Test func funcchartmodel_setAxis_updates_correct_axis_only() async throws {
        var fm = try FuncChartModel(input: "x + y")

        // Capture originals to ensure others don't mutate
        let yBefore = fm.yAxis
        let zBefore = fm.zAxis

        try fm.setAxis(axis: .x, max: 10, min: -10, steps: 0.5)

        try ensure(fm.xAxis.min == -10 && fm.xAxis.max == 10 && fm.xAxis.steps == 0.5,
                   "setAxis(.x) should update X axis values")
        try ensure(fm.yAxis.min == yBefore.min && fm.yAxis.max == yBefore.max && fm.yAxis.steps == yBefore.steps,
                   "setAxis(.x) should NOT mutate Y")
        try ensure(fm.zAxis.min == zBefore.min && fm.zAxis.max == zBefore.max && fm.zAxis.steps == zBefore.steps,
                   "setAxis(.x) should NOT mutate Z")
    }

    @Test func funcchartmodel_setAxis_throws_when_min_greater_than_max() async throws {
        var fm = try FuncChartModel(input: "x")
        do {
            try fm.setAxis(axis: .y, max: 0, min: 1, steps: 1)
            throw TestFailure.fail("Expected setAxis to throw when min > max")
        } catch let e as AppError {
            try ensure(e == .minGreaterThanMax, "Expected .minGreaterThanMax but got \(e)")
        }
    }

    @Test func funcchartmodel_setAxis_allows_equal_min_max() async throws {
        var fm = try FuncChartModel(input: "x")
        // min == max is allowed by the model (guard min <= max)
        try fm.setAxis(axis: .z, max: 2.0, min: 2.0, steps: 1.0)
        try ensure(fm.zAxis.min == 2.0 && fm.zAxis.max == 2.0,
                   "min==max should be allowed and set on Z axis")
    }

    @Test func funcchartmodel_setInput_reparses_and_keeps_axes() async throws {
        var fm = try FuncChartModel(input: "x+1")
        // Change axes to non-defaults
        try fm.setAxis(axis: .x, max: 20, min: -20, steps: 2)

        // Evaluate before changing input
        let before = try fm.ast.eval(2.0, 0.0) // x=2 -> 3
        try ensure(before == 3.0, "Expected x+1 at x=2 to be 3 before update")

        // Update function
        try fm.setInput("x*2")

        // Evaluate after changing input
        let after = try fm.ast.eval(2.0, 0.0) // x=2 -> 4
        try ensure(after == 4.0, "Expected x*2 at x=2 to be 4 after update")

        // Axes should remain as previously set
        try ensure(fm.xAxis.min == -20 && fm.xAxis.max == 20 && fm.xAxis.steps == 2,
                   "setInput should NOT reset axis configuration")
    }

    @Test func funcchartmodel_setAxis_updates_each_axis_path() async throws {
        var fm = try FuncChartModel(input: "x+y")

        try fm.setAxis(axis: .x, max: 9, min: -9, steps: 3)
        try ensure(fm.xAxis.min == -9 && fm.xAxis.max == 9 && fm.xAxis.steps == 3,
                   "X axis should update via .x path")

        try fm.setAxis(axis: .y, max: 8, min: -8, steps: 2)
        try ensure(fm.yAxis.min == -8 && fm.yAxis.max == 8 && fm.yAxis.steps == 2,
                   "Y axis should update via .y path")

        try fm.setAxis(axis: .z, max: 7, min: -7, steps: 1)
        try ensure(fm.zAxis.min == -7 && fm.zAxis.max == 7 && fm.zAxis.steps == 1,
                   "Z axis should update via .z path")
    }


}
