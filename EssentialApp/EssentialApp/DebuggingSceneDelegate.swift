//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by AmritPandey on 07/11/22.
//
#if DEBUG

import UIKit
import EssentialFeed

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreUrl)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AnyFailingHttpClient()
        }
       return super.makeRemoteClient()
    }
    
}

private class AnyFailingHttpClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
#endif
