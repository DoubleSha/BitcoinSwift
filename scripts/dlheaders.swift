#!/usr/bin/swift -F /Library/Frameworks

import BitcoinSwift
import Foundation

class BlockHeaderDownloader {

  init() {}

  let semaphore = dispatch_semaphore_create(0)

  func downloadBlockHeaders() {
    let peerController = PeerController(hostname: "localhost",
                                        port: 8333,
                                        network: Message.Network.MainNet,
                                        blockStore: InMemorySPVBlockStore(),
                                        queue: NSOperationQueue())
    peerController.start()
    waitWithTimeout(6000)
  }

  func waitWithTimeout(seconds: Int) {
    let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC))
    dispatch_semaphore_wait(semaphore, timeout)
  }
}

extension BlockHeaderDownloader: PeerControllerDelegate {

  func blockChainSyncComplete() {
    dispatch_semaphore_signal(semaphore)
  }
}

let blockHeaderDownloader = BlockHeaderDownloader()
blockHeaderDownloader.downloadBlockHeaders()
println("DONE")
