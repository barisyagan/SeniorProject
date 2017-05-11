//
//  PlaneTests.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/10/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import XCTest
import SpriteKit
@testable import SeniorProject

class PlaneTests: XCTestCase {
    
    var planeUnderTest: Plane!
    
    
    override func setUp() {
        
        super.setUp()
        
        
        planeUnderTest = Plane(imageName: "player", size: CGSize(width: 1080, height: 1920))
        
        
        
        
    }
    
    override func tearDown() {
        
        planeUnderTest = nil
        
        
        
        
        super.tearDown()
    }

    
    func testPlaneInitImageName() {
        XCTAssertEqual(planeUnderTest.imageName, "player")
    }
    
    func testPlaneInitSize() {
        XCTAssertEqual(planeUnderTest.size, CGSize(width: 1080, height: 1920))
    }
    
    func testPlaneInitNode() {
        XCTAssertNotNil(planeUnderTest.node)
    }
    
    func testPlaneInitNodeName() {
        XCTAssertEqual(planeUnderTest.node.name, "player")
    }
    
    func testPlaneInitXScale() {
        XCTAssertEqual(planeUnderTest.node.xScale, 1)
    }
    
    func testPlaneInitYScale() {
        XCTAssertEqual(planeUnderTest.node.yScale, 1)
    }
    
    func testPlaneInitAffectedByGravity() {
        XCTAssertEqual(planeUnderTest.node.physicsBody?.affectedByGravity, false)
    }
    
    func testPlaneInitCategoryBitMask() {
        XCTAssertEqual(planeUnderTest.node.xScale, 0b1)
    }
    
    func testPlaneInitCollisionBitMask() {
        XCTAssertEqual(planeUnderTest.node.physicsBody?.collisionBitMask, 0)
    }
    
    func testPlaneInitContactBitMask() {
        XCTAssertEqual(planeUnderTest.node.physicsBody?.contactTestBitMask, 0b10)
        
    }
    
    func testPlaneInitChildFire() {
        XCTAssertNotNil(planeUnderTest.node.childNode(withName: "fireParticle"))
    }
    
    func testPlaneInitChildSmoke() {
        XCTAssertNotNil(planeUnderTest.node.childNode(withName: "smokeParticle"))
    }
    
    func testPlaneInitFireParticleName() {
        XCTAssertEqual(planeUnderTest.fireParticle?.name, "fireParticle")
    }
    
    func testPlaneInitSmokeParticleName() {
        XCTAssertEqual(planeUnderTest.smokeParticle?.name, "smokeParticle")
    }
    
    func testPlaneInitYCoor() {
        XCTAssertEqual(planeUnderTest.yCoor, 180)
    }
    
    func testMoveLeftYCoorFirstTouch() {
        let yCoorShouldBe = planeUnderTest.yCoor + 40
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.yCoor, yCoorShouldBe)
    }
    
    func testMoveRightYCoorFirstTouch() {
        planeUnderTest.pokeToMove()
        let yCoorShouldBe = planeUnderTest.yCoor + 40
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.yCoor, yCoorShouldBe)
    }
    
    func testMoveLeftYCoorManyTouch() {
        planeUnderTest.pokeToMove()
        planeUnderTest.pokeToMove()
        
        let yCoorShouldBe = planeUnderTest.yCoor + 40
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.yCoor, yCoorShouldBe)
    }
    
    func testMoveRightYCoorManyTouch() {
        planeUnderTest.pokeToMove()
        planeUnderTest.pokeToMove()
        planeUnderTest.pokeToMove()
        
        let yCoorShouldBe = planeUnderTest.yCoor + 40
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.yCoor, yCoorShouldBe)
    }
    
    func testMoveLeftDirectionFirstTouch() {
        let directionShouldBe = false
        
        XCTAssertEqual(planeUnderTest.direction, directionShouldBe)
    }
    
    func testMoveRightDirectionSecondTouch() {
        
        let directionShouldBe = true
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.direction, directionShouldBe)
    }
    
    func testMoveLeftDirectionThirdTouch() {
        planeUnderTest.pokeToMove()
        
        let directionShouldBe = false
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.direction, directionShouldBe)
    }
    
    func testMoveRightDirectionForthTouch() {
        planeUnderTest.pokeToMove()
        planeUnderTest.pokeToMove()
        
        let directionShouldBe = true
        
        planeUnderTest.pokeToMove()
        
        XCTAssertEqual(planeUnderTest.direction, directionShouldBe)
    }
}
