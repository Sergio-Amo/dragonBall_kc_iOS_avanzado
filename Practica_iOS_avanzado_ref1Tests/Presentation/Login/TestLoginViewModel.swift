//
//  TestLoginViewModel.swift
//  Practica_iOS_avanzado_ref1Tests
//
//  Created by Sergio Amo on 19/2/24.
//

import Foundation
import XCTest

@testable import Practica_iOS_avanzado_ref1

final class TestLoginViewModel: XCTestCase {
    // SUT
    private var sut: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        let networkApi = FakeNetworkApiSuccess(vaultApi: FakeVaultApi())
        sut = LoginViewModel(networkApi: networkApi)
    }
    
    func test_isValidMail() {
        // Happy path
        let validMails = [
            "valid@mail.com",
            "is@valid.es",
            "valid.mail@kc.net"
        ]
        validMails.forEach { XCTAssertTrue(sut.isValid(email: $0)) }
        // Unhappy path
        let invalidMails = [
            "is@almostValid.",
            "@not.valid",
            "thsDoesNot.work",
            "foo.bar"
        ]
        invalidMails.forEach { XCTAssertFalse(sut.isValid(email: $0)) }
    }
    
    func test_isValidPassword() {
        // Happy path
        let validPasswords = [
            "valid",
            "asmn123s",
            "·%$%nashdt"
        ]
        validPasswords.forEach { XCTAssertTrue(sut.isValid(password: $0)) }
        // Unhappy path
        let invalidPassword = [
            "123",
            "xx",
            "a",
            "foo"
        ]
        invalidPassword.forEach { XCTAssertFalse(sut.isValid(password: $0)) }
    }
    
    
    func test_onLoginPressed_HappyPath() {
        let expectation = self.expectation(description: "Login successful")
        
        sut.viewState = { state in
            if case .navigateToNext = state {
                expectation.fulfill()
            }
        }
        
        sut.onLoginPressed(email: "valid@mail.com", password: "ValidPassword")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_OnLoginPressed_InvalidMail() {
        let expectation = self.expectation(description: "Invalid mail error")
        
        sut.viewState = { state in
            if case .showErrorEmail(_) = state {
                expectation.fulfill()
            }
        }
        
        sut.onLoginPressed(email: "invalidMial", password: "ValidPassword")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_OnLoginPressed_InvalidPassword() {
        let expectation = self.expectation(description: "Invalid password error")
        
        sut.viewState = { state in
            if case .showErrorPassword(_) = state {
                expectation.fulfill()
            }
        }
        
        sut.onLoginPressed(email: "valid@mail.com", password: "x")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_doLogin_HappyPath() {
        let expectation = self.expectation(description: "Navigate to next")
        
        sut.viewState = { state in
            if case .navigateToNext = state {
                expectation.fulfill()
            }
        }
        
        sut.doLoginWith(email: "valid@mail.com", password: "123456")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_doLogin_unHappyPath() {
        // Use a FakeNetworkApi that always fails
        let sut = LoginViewModel(networkApi: FakeNetworkApiFailure(vaultApi: FakeVaultApi()))
        
        let expectation = self.expectation(description: "Network Error")
        
        sut.viewState = { state in
            if case .showToast((_,_)) = state {
                expectation.fulfill()
            }
        }
        
        sut.doLoginWith(email: "foo", password: "bar")
        sut.doLoginWith(email: "foo", password: "bar")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
