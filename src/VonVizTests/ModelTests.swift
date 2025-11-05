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
        let domain = try ai.getDomain()
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
        try ensure(ai.header == "" && ai.min == -50 && ai.max == 50, "Expected default AxisInfo values")
    }

}

extension ModelTests {
    /// Run all model tests as a suite (callable from main test entry)
    static func run() async throws {
        let inst = ModelTests()
        try await inst.axisinfo_domain_and_defaults()
        try await inst.datamodel_render_without_dataset_throws()
        try await inst.ingest_and_render_and_axis_ranges()
        try await inst.ingest_not_enough_columns_throws()
        try await inst.set_axis_domain_validation()
        try await inst.ingest_skips_nan_rows()
        try await inst.funcchartmodel_parses_and_evaluates_ast()
        try await inst.get_axis_info_returns_struct()
    }
}
