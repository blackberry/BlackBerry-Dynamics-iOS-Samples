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
//This extention is used to resign the Keyboard when the user touches anywhere on the screen
extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

@UIApplicationMain
class AppDelegate : UIResponder , UIApplicationDelegate,  GDiOSDelegate {
    var window: UIWindow?

    var good: GDiOS?
    var started: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    //Call BlackBerry Dynamics to authorise the app
    self.good = GDiOS.sharedInstance()
         
    self.good!.delegate = self
    self.started = false
        
    // Show the Good Authentication UI.
    self.good!.authorize()
           
    return true
}


func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



// MARK: - Good Dynamics Delegate Methods

func handle(_ anEvent: GDAppEvent) {
     
    switch anEvent.type {
            case .authorized:
                onAuthorized(anEvent: anEvent)
                break
               
            case .notAuthorized:
                self.onNotAuthorized(anEvent: anEvent)
                break
                
            case .remoteSettingsUpdate:
                if started {
                   
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
                    self.window?.rootViewController = newViewController
                    newViewController.refreshUI()

    
                }
                break
          
            case .servicesUpdate:
                //A change to services-related configuration.
                break
                  
             case .policyUpdate:
                if started {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppPolicyUpdated"), object: nil);
                }
                break
    
        
            default:
                print("handleEvent \(anEvent.message)")
            }
}

    
func onNotAuthorized(anEvent:GDAppEvent ) {
    /* Handle the Good Libraries not authorized event. */
    switch anEvent.code {
        case .errorActivationFailed: break
        case .errorProvisioningFailed: break
        case .errorPushConnectionTimeout: break
        case .errorSecurityError: break
        case .errorAppDenied: break
        case .errorAppVersionNotEntitled: break
        case .errorBlocked: break
        case .errorWiped: break
        case .errorRemoteLockout: break
        case .errorPasswordChangeRequired:
            // an condition has occured denying authorization, an application may wish to log these events
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            // idle lockout is benign & informational
            break

        default: assert(false, "Unhandled not authorized event");
        }
}
    

    
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
    


    
    func onAuthorized(anEvent:GDAppEvent ) {
        /* Handle the Good Libraries authorized event. */
        switch anEvent.code {
            case .errorNone:
                if !self.started {
                    //Show the User UI
                    self.started = true
                    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController")
                }
            default:
                assert(false, "Authorized startup with an error")
                break
            }
    }

}
                            
