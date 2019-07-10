//
//  FetchAudioCommentOperation.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/15/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    init(comment: Comment, postController: PostController, session: URLSession = URLSession.shared) {
        self.comment = comment
        self.postController = postController
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        
        guard let url = comment.audioURL else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.comment): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }
            
            self.audioData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let comment: Comment
    let postController: PostController
    var audioData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
}
