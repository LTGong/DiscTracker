//
//  BarGraphViewController.swift
//  DiscussionTracker1
//
//  Created by Liam Gong on 5/16/16.
//  Copyright © 2016 Liam Gong. All rights reserved.
//

import Foundation
import UIKit

class contBarGraph{
    let contributions: Array<Contribution>
    init(withContributions conts: Array<Contribution>){
        self.contributions = conts;
    }
    
    var cols:colList {
        var columnList = Array<barColumn>()
        for contrib in contributions{
            let col = barColumn(name: contrib.contributor.initials, color: contrib.contributor.color, duration: contrib.duration)
            columnList.append(col)
        }
        return colList(columns: columnList)
    }
}

struct colList{
    let columns: Array<barColumn>
    var count:Int{
        return self.columns.count
    }
    var maxVal:Double{
        var max = 0.0
        for col in columns{
            let dur = Double(col.duration)
            if dur > max{
                max = dur
            }
        }
        return max
    }
}

struct barColumn {
    let name:String
    let color:UIColor
    let duration:NSTimeInterval
}

class BarGraphViewController:UIViewController{
    //iVars:
    var barModel = contBarGraph(withContributions:Array<Contribution>())//refactor for viewController initializers
    
    @IBOutlet weak var displayText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayData(){
        if self.barModel.contributions.count != 0{
            self.displayText.text! = ""
            let buttonArr = self.generateButtons()
            /*for but in buttonArr{
                self.view!.addSubview(but)
            }*/
        }else{
            self.displayText.text! = "Please track a discussion to see the duration bar chart."
        }
        
    }
    
    func generateButtons()->Array <UIButton>{
        let maxHeight = Double(self.view.frame.height) * 0.8
        let spaceWidth =  Double(self.view.frame.width) / Double(self.barModel.cols.count)
        let width = 0.8*spaceWidth// TK magic #!
        //var butArr = Array<UIButton>()
        let whatTheHell = self.barModel.cols
        let whatTheHellList = whatTheHell.columns
        for ind in 0..<whatTheHellList.count{
            let col = self.barModel.cols.columns[ind]
            let height = (maxHeight * Double(col.duration))/self.barModel.cols.maxVal
            let yOrigin = Double(self.view.frame.height) - height
            let xOrigin = Double(ind) * Double(self.view.frame.width) / Double(self.barModel.cols.count) + (spaceWidth - width)/2.0
            let butRect = CGRect(x: xOrigin , y: yOrigin, width: width, height: height)
            let button = UIButton(frame: butRect)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitle(col.name, forState: UIControlState.Normal)
            button.backgroundColor = col.color
            self.view.addSubview(button)
        }
        return Array <UIButton>()//butArr
    }

}