//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by AmritPandey on 13/09/22.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image  {
    private let feedImage: View?
    private let imageTransformer: ((Data) -> Image?)
    
    private struct InvalidImageDataError: Error {}
    
    public init(feedImage: View, imageTranformer: @escaping ((Data) -> Image?)) {
        self.feedImage = feedImage
        self.imageTransformer = imageTranformer
    }
    
    public func didStartLoadingImage(model: FeedImage) {
        feedImage?.display(FeedImageViewModel(isLoading: true,
                                              shoulretry: false,
                                              description: model.description,
                                              location: model.location,
                                              image: nil))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        feedImage?.display(FeedImageViewModel(isLoading: false,
                                              shoulretry: image == nil,
                                              description: model.description,
                                              location: model.location,
                                              image: image))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        feedImage?.display(FeedImageViewModel(isLoading: false,
                                              shoulretry: true,
                                              description: model.description,
                                              location: model.location,
                                              image: nil))
    }
}
