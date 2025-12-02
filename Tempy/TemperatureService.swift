//
//  TemperatureService.swift
//  Tempy
//

import Foundation
import Combine

@MainActor
class TemperatureService: ObservableObject {
    @Published var temperatureData: TemperatureData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    private static let apiURLString = "https://your-worker.workers.dev"
    private static let apiURL = URL(string: apiURLString)!
    private static let requestTimeout: TimeInterval = 10.0
    private static let refreshInterval: TimeInterval = 60.0
    
    private var refreshTimer: Timer?
    private var currentTask: Task<Void, Never>?
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Self.requestTimeout
        configuration.timeoutIntervalForResource = Self.requestTimeout + 5.0
        return URLSession(configuration: configuration)
    }()
    
    init() {
        fetchTemperature()
        startAutoRefresh()
    }
    
    func fetchTemperature() {
        guard !isLoading else { return }
        
        currentTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        
        currentTask = Task { @MainActor in
            do {
                let (data, response) = try await urlSession.data(from: Self.apiURL)
                
                guard !Task.isCancelled else { return }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.isLoading = false
                    self.errorMessage = "Invalid server response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.isLoading = false
                    self.errorMessage = "Server error (HTTP \(httpResponse.statusCode))"
                    return
                }
                
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(TemperatureData.self, from: data)
                
                guard !Task.isCancelled else { return }
                self.temperatureData = decodedData
                self.lastUpdateTime = Date()
                self.errorMessage = nil
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        self.errorMessage = "Request timed out"
                    case .notConnectedToInternet:
                        self.errorMessage = "No internet connection"
                    case .networkConnectionLost:
                        self.errorMessage = "Network connection lost"
                    default:
                        self.errorMessage = "Network error"
                    }
                } else {
                    self.errorMessage = "Failed to fetch temperature data"
                }
            }
        }
    }
    
    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.fetchTemperature()
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
        currentTask?.cancel()
    }
}

