import UIKit
import CoreMotion
import LocalAuthentication

var tremoringX : [Double] = [0.0]
var tremoringY : [Double] = [0.0]
var tremoringZ : [Double] = [0.0]
var SamePerson = true
var timer = Timer()
var mx: Float = 0.0, my: Float = 0.0, mz: Float = 0.0
var tried = false
let x = 0.0, y = 0.0, z = 0.0

class ViewController: UIViewController {
    var motion = CMMotionManager()
    
    @objc func cleararray() {
        
        if tried == false {
        if mx < 50 {
            tried = true
            self.authWithTouchID()
            }
            
        }
        
        tremoringX.removeAll()
        tremoringY.removeAll()
        tremoringZ.removeAll()
    }

    func scheduledTimerWithTimeInterval(){

            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.cleararray), userInfo: nil, repeats: true)

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            myGyroscope()
        
            unowned let unownedSelf = self
        
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                unownedSelf.scheduledTimerWithTimeInterval()
            })
        
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        sleep(5)
    }
    
    func calculateMedian(array: [Double]) -> Float {
        let sorted = array.sorted()
        if sorted.count % 2 == 0 {
            return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
        } else {
            return Float(sorted[(sorted.count - 1) / 2])
        }
    }
    
    func authWithTouchID() {
        //TO-DO: Authenticate with Password option
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Our systems could not recognize this activity, please try again"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        //show deactivate popup
                        //self.showAlertController("Touch ID Authentication Succeeded")
                        let alert = UIAlertController(title: "Are you sharing the app with another person?", message: "If yes, you can disable the identity check until next app launch", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Disable for 5 minutes", comment: "5min"), style: .cancel, handler: { _ in
                            NSLog("The \"5min\" alert occured.")
                        }))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Disable until next launch", comment: "Nextlaunch"), style: .default, handler: { _ in
                            NSLog("The \"nextlaunch\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        //pop to login screen
                        self.showAlertController("Due to suspicious activity, our systems have disabled your e-banking account temporarily. You will be logged out.")
                        self.logout()
                        
                    }
            })
        }
        else {
            showAlertController("Touch ID not available")
        }
    }
    
    func logout() {
        //#TO-DO logout speed extremely slow, especially label display speed
        // UI API called from background thread
        // but UIApplication application state must be used from main thread only
        // likely conflict caused slow speed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "fail") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func myGyroscope() {
        print("Start Accelerometer")
        motion.gyroUpdateInterval = 0.1
        motion.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                
                self.view.reloadInputViews()
                let x = abs(trueData.rotationRate.x)
                let y = abs(trueData.rotationRate.y)
                let z = abs(trueData.rotationRate.z)
                
                tremoringX.append(x)
                tremoringY.append(y)
                tremoringZ.append(z)
                
                mx = Float(self.calculateMedian(array: tremoringX)*1000)
                my = Float(self.calculateMedian(array: tremoringY)*1000)
                mz = Float(self.calculateMedian(array: tremoringZ)*1000)

            }
        }
        
        return
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
