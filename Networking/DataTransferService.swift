
import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
	case unKnownError
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
	
	var apiFailureIntercepter : ((Any, Int, Bool, URLRequest?) -> ()) {get set}
	var networkAndOtherErrorIntercepter : (DataTransferError, Bool, URLRequest?) -> () {get set}
  
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                     completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    @discardableResult
    func request<E: ResponseRequestable>(with endpoint: E,
                                       completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E.Response == Void
	@discardableResult
	func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
																														apiSuccess: @escaping (T)->(),
																														apiFailure: (([String:Any])->())?,
																														otherError : ((DataTransferError)->())? ) -> NetworkCancellable? where E.Response == T
	
	@discardableResult
	func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
																										 apiSuccess: @escaping (T)->()
																										 ) -> NetworkCancellable? where E.Response == T

	@discardableResult
	func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
																										 apiSuccess: @escaping (T)->(),
																										 apiFailure: @escaping ([String:Any])->()
	) -> NetworkCancellable? where E.Response == T
	
	@discardableResult
	func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
																										 apiSuccess: @escaping (T)->(),
																										 otherError : @escaping (DataTransferError)->()
	) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable,F:Decodable, E: ResponseRequestable>(with endpoint: E,
                                                                                                                        apiSuccess: @escaping (T)->(),
                                                                   apiFailureDecodable: ((F, HTTPStatusCode?)->())?,
                                                                                                                        otherError : ((DataTransferError)->())? ) -> NetworkCancellable? where E.Response == T
	
	

}

public protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public protocol DataTransferErrorLogger {
    func log(error: Error)
}

public final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
	public var apiFailureIntercepter : (Any, Int, Bool, URLRequest?) -> ()
	public var networkAndOtherErrorIntercepter : (DataTransferError, Bool, URLRequest?) -> ()
    
    public init(with networkService: NetworkService,
                errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
				errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger(),
				apiFailureInterceptor : @escaping ((Any, Int, Bool, URLRequest?) -> ()),
				networkAndOtherErrorIntercepter : @escaping ((DataTransferError, Bool, URLRequest?) -> ())) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
		self.apiFailureIntercepter = apiFailureInterceptor
		self.networkAndOtherErrorIntercepter = networkAndOtherErrorIntercepter
    }
}

extension DefaultDataTransferService: DataTransferService {
	
	
	public func request<T: Decodable,F:Decodable, E: ResponseRequestable>(with endpoint: E,
																														apiSuccess: @escaping (T)->(),
																														apiFailureDecodable: ((F, HTTPStatusCode?)->())?,
																														otherError : ((DataTransferError)->())? ) -> NetworkCancellable? where E.Response == T {
		
        return self.networkService.request(endpoint: endpoint) { result, statusCode, urlRequest  in
			switch result {
				case .success(let data):
					
					if !(200...299).contains(statusCode!) {
						let result: Result<F, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
						
						DispatchQueue.main.async {
							switch result {
								case .success(let response) :
                                    self.apiFailureIntercepter(result, statusCode ?? 0, apiFailureDecodable == nil ? false : true, urlRequest)
                                apiFailureDecodable?(response, HTTPStatusCode(rawValue: statusCode!))
								case .failure(let error) :
                                    self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
									otherError?(error)
							}
						}
						
					} else {
						let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
						
						DispatchQueue.main.async {
							switch result {
								case .success(let response) :
									apiSuccess(response)
								case .failure(let error) :
                                    self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
									otherError?(error)
							}
						}
					}
					
				case .failure(let error):
					self.errorLogger.log(error: error)
					let error = self.resolve(networkError: error)
					DispatchQueue.main.async {
                        self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
						otherError?(error)
					}
			}
		}
	}
	
	
	public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
																																					 apiSuccess: @escaping (T)->(),
																														apiFailure: (([String:Any])->())?,
																																					 otherError : ((DataTransferError)->())? ) -> NetworkCancellable? where E.Response == T {
		
		return self.networkService.request(endpoint: endpoint) { result, statusCode, urlRequest in
			switch result {
				case .success(let data):
					if !(200...299).contains(statusCode!) {
						let result: Result<[String:Any], DataTransferError> = self.decodeToDict(data: data)
						DispatchQueue.main.async {
							switch result {
								case .success(let response) :
                                    self.apiFailureIntercepter(result, statusCode ?? 0, apiFailure == nil ? false : true, urlRequest)
									apiFailure?(response)
								case .failure(let error) :
                                    self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
									otherError?(error)
							}
						}
					} else {
						let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
						DispatchQueue.main.async {
							switch result {
								case .success(let response) :
									apiSuccess(response)
								case .failure(let error) :
                                    self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
									otherError?(error)
							}
						}
					}
					
				case .failure(let error):
					self.errorLogger.log(error: error)
					let error = self.resolve(networkError: error)
					DispatchQueue.main.async {
                        self.networkAndOtherErrorIntercepter(error, otherError == nil ? false : true, urlRequest)
						otherError?(error)
					}
			}
		}
	}
	
	
	public func request<T, E>(with endpoint: E, apiSuccess: @escaping (T) -> ()) -> NetworkCancellable? where T : Decodable, T == E.Response, E : ResponseRequestable {
		return self.request(with: endpoint, apiSuccess: apiSuccess, apiFailure: nil, otherError: nil)
	}
	
	public func request<T, E>(with endpoint: E, apiSuccess: @escaping (T) -> (), apiFailure: @escaping ([String : Any]) -> ()) -> NetworkCancellable? where T : Decodable, T == E.Response, E : ResponseRequestable {
		return self.request(with: endpoint, apiSuccess: apiSuccess, apiFailure: apiFailure, otherError: nil)
	}
	
	public func request<T, E>(with endpoint: E, apiSuccess: @escaping (T) -> (), otherError: @escaping (DataTransferError) -> ()) -> NetworkCancellable? where T : Decodable, T == E.Response, E : ResponseRequestable {
		return self.request(with: endpoint, apiSuccess: apiSuccess, apiFailure: nil, otherError: otherError)
	}
	
	func handleApiFailure() {
		
	}
    
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {

        return self.networkService.request(endpoint: endpoint) { result, statusCode, urlRequest  in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    public func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        return self.networkService.request(endpoint: endpoint) { result, statusCode , urlRequest in
            switch result {
            case .success:
                DispatchQueue.main.async { return completion(.success(())) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    // MARK: - Private
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            
            // handling for event router when response is not json. Response is string.
            if T.self == String.self {
                return .success(String(data: data, encoding: .utf8) as! T)
            }
            
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
	
	private func decodeToDict(data: Data?) -> Result<[String : Any], DataTransferError> {
		do {
			guard let results = try JSONSerialization.jsonObject(with: data!) as? [String:Any] else {return .failure(.noResponse)}
			return .success(results)
		} catch {
			self.errorLogger.log(error: error)
			return .failure(.parsing(error))
		}
	}
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}

// MARK: - Logger
public final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}

// MARK: - Error Resolver
public class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    public init() { }
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}

// MARK: - Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private var jsonDecoder : JSONDecoder {
        let decoder = JSONDecoder.init()
//		decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-d hh:mm a"
        
        let iso8601Full: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }()
        
        decoder.dateDecodingStrategy =  .formatted(iso8601Full)
        return decoder
    }
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
