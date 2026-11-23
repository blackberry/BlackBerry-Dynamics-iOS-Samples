/* Copyright (c) 2016 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import UIKit
import CoreData
import BlackBerryDynamics.Runtime
import BlackBerryDynamics.SecureStore.CoreData

// This extension is used to resign the Keyboard when the user touches anywhere on the screen
extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GDiOS.sharedInstance().authorize(GettingStartedGDiOSDelegate.shared)
        
        return true
    }

    // MARK: - UISceneSession lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = GettingStartedSceneDelegate.self
        sceneConfig.sceneClass = UIWindowScene.self
        return sceneConfig
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }



    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
       // The directory the application uses to store the Core Data store file. This code uses a directory named "com.good.example.CoreData1" in the application's documents Application Support directory.
       let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
       return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
           // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
           let modelURL = Bundle.main.url(forResource: "ColorModel", withExtension: "momd")!
           return NSManagedObjectModel(contentsOf: modelURL)!
    }()


    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
          // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
          // Create the coordinator and store
          let coordinator = GDPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
          let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
          var failureReason = "There was an error creating or loading the application's saved data."
          do {
              try coordinator.addPersistentStore(ofType: GDEncryptedIncrementalStoreType, configurationName: nil, at: url, options: nil)
          } catch {
              // Report any error we got.
              var dict = [String: AnyObject]()
              dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
              dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

              dict[NSUnderlyingErrorKey] = error as NSError
              let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
              // Replace this with code to handle the error appropriately.
              // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
              abort()
          }

          return coordinator
      }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()


    func saveContext () {
        if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
    }
}
