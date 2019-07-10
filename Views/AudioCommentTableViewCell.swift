//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/15/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentTableViewCellDelegate: class {
    func playRecording(for cell: AudioCommentTableViewCell)
}

class AudioCommentTableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playRecordingButton.isEnabled = false
    }
    
    @IBAction func playRecording(_ sender: Any) {
        delegate?.playRecording(for: self)
    }
    
    func updateViews() {
        guard let comment = comment else { return }
        authorLabel.text = comment.author.displayName
    }
    
    weak var delegate: AudioCommentTableViewCellDelegate?

    var audioData: Data! {
        didSet {
            playRecordingButton.isEnabled = audioData != nil 
        }
    }
    var comment: Comment! {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playRecordingButton: UIButton!
    
}
