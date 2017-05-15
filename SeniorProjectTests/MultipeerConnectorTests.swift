//
//  MultipeerConnectorTests.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/13/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import XCTest
@testable import SeniorProject

class MultipeerConnectorTests: XCTestCase {
    
    var mc: MultipeerConnector!
  
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
       
        mc = MultipeerConnector()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mc = nil
        
        super.tearDown()
    }
    
    func testGetMinute() {
        let date = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)

        let minuteShouldBe = minute
        
        let minuteThatMethodReturns = mc.getMinute()
        
        XCTAssertEqual(minuteShouldBe, minuteThatMethodReturns)
    }
    
    func testFromIntToData() {
        let testInt = 10
        var value = testInt
        let dataShouldBe = withUnsafePointer(to: &value) {
            Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: testInt))
        }
                let dataThatMethodReturns = mc.fromIntToData(minute: 10)
        
        XCTAssertEqual(dataShouldBe, dataThatMethodReturns)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
