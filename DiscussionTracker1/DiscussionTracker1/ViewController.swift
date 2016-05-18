//
//  ViewController.swift
//  DiscussionTracker1
//
//  Created by Liam Gong on 5/12/16.
//  Copyright © 2016 Liam Gong. All rights reserved.
//

import UIKit

//Model

class Discussion{
    let title:String;
    let classroom:Classroom;
    var conns:ConnectionGraph;
    
    //var durations = [Contributor:NSTimeInterval]()
    
    var contributions = Array<Contribution>();//TK: encapslate in object to pass to barGraph?
    
    func addContribution(cont:Contribution){
        if (self.lastContributor != nil){
            conns.increment(fromContributor: self.lastContributor!, toContributor: cont.contributor)
        }
        self.contributions.append(cont);
       // self.durations[cont.contributor] += cont.duration
    }
    
    //Necesssary? Should this logic reside in View or Model?
    var lastContributor: Contributor?{
        if (self.contributions.last != nil){
            return self.contributions.last!.contributor
        }else{
            return nil
        }
    }
    
    init(fromTitle title:String, withRoom room:Classroom){
        self.title = title;
        self.classroom = room;
        self.conns = ConnectionGraph(withRoster: room.roster);
        /*for con in room.roster{
            durations[con] = 0.0;
        }
 */
    }
    convenience init(){
        let nameArray = ["Anthony Jonikas",
                         "Bella Hutchins",
                         "Kate Palmer",
                         "Liam Gong",
                         "Markus Feng",
                         "Ben Bakker",
                         "Aditya Jha",
                         "Jack Xu",
                         "Will Ughetta"];
        var sampleContributors = Array<Contributor>();
        for entry in nameArray{
            let first = entry.componentsSeparatedByString(" ")[0];
            let last = entry.componentsSeparatedByString(" ")[1];
            sampleContributors.append(Contributor(firstName: first, lastName: last, color: randomColor()));
        }
        self.init(fromTitle: "Example Discussion", withRoom: Classroom(title: "Example Classroom", roster: sampleContributors));
    }
}

class ConnectionGraph{
    var doubleDict = [Contributor:[Contributor:Int]]()
    
    func count(fromContributor contOne:Contributor, toContributor contTwo: Contributor)-> Int{
        return self.doubleDict[contOne]![contTwo]!;
    }
    
    func increment(fromContributor contOne:Contributor, toContributor contTwo: Contributor){
        self.doubleDict[contOne]![contTwo]! += 1;
    }
    
    init(withRoster roster:Array<Contributor>){
        for senderCont in roster{
            var recDict = [Contributor:Int]()
            for receiverCont in roster{
                recDict[receiverCont] = 0;
            }
            doubleDict[senderCont] = recDict
        }
    }
}


struct Contribution{
    var contributor:Contributor;
    var timeBegun:NSDate;
    var timeEnded:NSDate;
    var duration:NSTimeInterval{
        return timeEnded.timeIntervalSinceDate(timeBegun)
    }
}

struct Contributor:Hashable{
    var firstName:String;
    var lastName:String;
    var color:UIColor;
    
    
    var hashValue: Int{ // currently, only unique iff first & last are same. Could include color, but random # probably not good idea. TK: UID?
        return firstName.stringByAppendingString(lastName).hashValue
    }
    
    var initials: String{
        let firstInital = self.firstName.capitalizedString[self.firstName.capitalizedString.startIndex];
        let secondInitial = self.lastName.capitalizedString[self.lastName.capitalizedString.startIndex];
        return String(firstInital).stringByAppendingString(String(secondInitial));
    }
    
    //TK: image?
}
func ==(lhs:Contributor, rhs:Contributor)-> Bool{
    return (lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName)
}

struct Classroom{
    var title:String;
    var roster:Array<Contributor>;
}

//Helpers

func randomColor() -> UIColor{
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}


//ViewController

class ViewController: UIViewController {
    
    //instance variables
    var discMod = Discussion()
    var buttons = [UIButton]()//Necessary - or can we let go of the button array?
    
    var currCont:Contribution?;
    var currButton:UIButton?;
    
    var lineLayer =  Array<CAShapeLayer>()// TK: this is bad.
    
    //guts
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayTable(withRoster: self.discMod.classroom.roster)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegation
    
    //Setup display from Model
    
    func displayTable(withRoster roster:Array<Contributor>) {
        for (index, cont) in roster.enumerate(){
            let button = self.button(fromContributor: cont)
            button.tag = index
            buttons.append(button)
        }
        var curAngle = M_PI/2// starts at bottom
        let incAngle = ( 360.0/(Double(buttons.count)) )*M_PI/180.0
        let circleCenter = self.view.center /* given center */
        let circleRadius = Double(self.view.frame.size.width/3) /* Big Circle Radius Coefficient. */
        for button in buttons
        {
            var buttonCenter = CGPoint()
            buttonCenter.x = circleCenter.x + CGFloat(cos(curAngle)*circleRadius)
            buttonCenter.y = circleCenter.y + CGFloat(sin(curAngle)*circleRadius)
            button.center = buttonCenter
            self.view.addSubview(button)
            
            curAngle += incAngle;
        }
        
    }
    
    func button(fromContributor cont: Contributor)-> UIButton{
        let myButton = UIButton(type: .Custom)
        myButton.setTitle(cont.initials, forState: .Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        myButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myButton.backgroundColor = cont.color
        myButton.frame = CGRectMake(0.0, 0.0, 150, 150) // button size const
        myButton.layer.cornerRadius = 0.5 * myButton.bounds.width;//make buttons circle-y
        myButton.addTarget(self, action: #selector(ViewController.pressedAction(_:)), forControlEvents: .TouchUpInside)
        return myButton
    }
    
    //updateDisplay
    func selectButton(myButton:UIButton){
        myButton.layer.borderWidth = 2.0
        myButton.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func deSelectButton(myButton:UIButton){
        myButton.layer.borderWidth = 0.0;
        myButton.layer.borderColor = UIColor.clearColor().CGColor // redundant, sure. TK Refactor: set all border color to black, then adjust width?
    }
    /*
    func displayDurations(forRoster roster:Array<Contributors>){
        var curAngle = M_PI/2// starts at bottom
        let circleCenter = self.view.center /* given center */
        let circleRadius = Double(self.view.frame.size.width/2) /* Big Circle Radius Coefficient. */
        let incAngle = ( 360.0/(Double(roster.length)) )*M_PI/180.0
        for (index, cont) in roster.enumerate(){
            
        }
    }
    */
    func onlyConnect(fromButton fromBut : UIButton, toButton toBut:UIButton){
        self.drawLineFromPoint(fromBut.center, toPoint: toBut.center, ofColor: UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5))
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor) {
        
        //design the path
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addQuadCurveToPoint(end, controlPoint: self.view.center)//TK: Set an independent object center.
        //path.addCurveToPoint(end, controlPoint1: self.view.center, controlPoint2: self.view.center)
        
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = lineColor.CGColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.view.layer.addSublayer(shapeLayer)
        self.lineLayer.append(shapeLayer)
    }
    
    //Interactivity
    func pressedAction(sender: UIButton!) {
        let btnSdr = sender;
        let cont = self.discMod.classroom.roster[btnSdr.tag];
        
        if (self.currCont != nil && !(self.currCont?.contributor == cont)){// tests that we've tapped a new button after tapping another button. Refactor: care only about buttons?
            currCont!.timeEnded = NSDate()
            self.discMod.addContribution(currCont!)
            self.deSelectButton(self.currButton!)
            
            //Change to Delegation from Model
            self.onlyConnect(fromButton: self.currButton!, toButton: btnSdr)
        }
        currCont = Contribution(contributor: cont, timeBegun: NSDate(), timeEnded: NSDate())
        currButton = btnSdr
        self.selectButton(btnSdr)
        
        //Debug:
        //NSLog("%i", btnSdr.tag)
        //NSLog(self.discMod.classroom.roster[btnSdr.tag].firstName)
    }
    
    @IBAction func clear(sender: UIButton) {
        NSLog("Clear!")
        self.discMod = Discussion()
        currCont = nil
        currButton = nil
        for layer in self.lineLayer{
            layer.removeFromSuperlayer()
        }
    }
    
    
    // Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BarDisplaySegue"{
            let targetController = segue.destinationViewController as! BarGraphViewController
            //targetController.displayText.text = "Hello World!"
            targetController.barModel = contBarGraph(withContributions: self.discMod.contributions)//encapsulate??
        }}
    
    //Helpers
    
    // !Makes assumption that index on Roster does not change throughout course of manipulation!
    //TK: Bad things will happen here - can we couple model objects to buttons more elegantly?
    func findButton(forContributor con: Contributor)->UIButton?{
        let tagIndex = self.discMod.classroom.roster.indexOf(con)
        if let button = self.view.viewWithTag(tagIndex!) as? UIButton {
            return button
        }else{
            return nil
        }
    }

}

