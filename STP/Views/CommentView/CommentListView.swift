//  CommentListView.swift
//  STP
//
//  Created by Eric Wong on 2/6/2024.
//

import SwiftUI
import RealmSwift

struct CommentListView: View {
    @ObservedResults(Comment.self) var comments
    @State private var createNewComment = false
    var placeId: ObjectId

    var filteredComments: Results<Comment> {
        return comments.filter("placeId == %@", placeId)
    }

    var body: some View {
        VStack {
            List {
                ForEach(filteredComments) { comment in
                    CommentRowView(comment: comment)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Comments")
            .overlay(alignment: .bottomTrailing, content: {
                Button(action: {
                    createNewComment.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.taskColor2)
                        .frame(width: 55, height: 55)
                        .background(.black.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
                })
                .padding(15)
            })
        }
        .sheet(isPresented: $createNewComment) {
            NewCommentView(isPresented: $createNewComment, placeId: placeId)
        }
    }
}

#Preview {
    let placeId = ObjectId.generate()
    return CommentListView(placeId: placeId)
}
