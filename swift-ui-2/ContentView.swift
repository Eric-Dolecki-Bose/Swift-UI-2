//
//  ContentView.swift
//  swift-ui-2
//
//  Created by Eric Dolecki on 2/25/20.
//  Copyright © 2020 Eric Dolecki. All rights reserved.
//

import SwiftUI
import Combine
import URLImage

struct Course: Decodable {
    let name, imageUrl: String
}

class NetworkManager: ObservableObject {
    @Published var courses = [Course]()
    
    func getAllCourses() {
        guard let url = URL(string: "https://api.letsbuildthatapp.com/jsondecodable/courses") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data!)
                DispatchQueue.main.async {
                    self.courses = courses
                }
            } catch {
                print("Failed To decode: ", error)
            }
        }.resume()
    }
}
 
struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    init(){
        UITableView.appearance().tableFooterView = UIView() //Remove rules below list.
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationView {
            List(networkManager.courses, id: \.name) { course in
                CourseRowView(course: course)
            }.navigationBarTitle(Text("Courses"))
        }.onAppear {
            self.networkManager.getAllCourses()
        }
    }
}

struct CourseRowView: View {
    let course: Course
    var body: some View {
        VStack (alignment: .leading) {
            
            URLImage(URL(string: course.imageUrl)!,
            delay: 0.25,
            processors: [ Resize(size: CGSize(width: UIScreen.main.bounds.width - 30, height: 150.0), scale: UIScreen.main.scale) ],
            
            content:  {
                $0.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
            }).frame(width :UIScreen.main.bounds.width - 30, height: 150.0)

            Text(course.name)
                .lineLimit(nil)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
     }
}

class ImageLoader: ObservableObject {
    @Published var data = Data()
    
    init(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
            
        }.resume()
    }
}

struct ImageViewWidget: View {
    
    @ObservedObject var imageLoader: ImageLoader
    
    init(imageUrl: String) {
        imageLoader = ImageLoader(imageUrl: imageUrl)
    }
    
    var body: some View {
        Image(uiImage: UIImage(data: imageLoader.data)!)
            .resizable()
            .frame(width:100, height: 100)
            .clipped()
    }
}



#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
