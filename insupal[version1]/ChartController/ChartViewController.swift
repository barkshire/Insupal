//  CMPT 276 Project Group 12 - Smart Apps
//  ChartViewController.swift
//
//
//  Created by MJ Jeon on 2018-07-04.
//  Copyright © 2018 cherrycat. All rights reserved.
//
// Updates the chart by retrieving the info from the Firebase database
import UIKit
import Charts
import Firebase
import FirebaseAuth
import Foundation

/*
class DateValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
    }
    //
    let formatter: DateFormatter
    
    init(formatter: DateFormatter) {
        self.formatter = formatter
    }
}


@objc(BarChartFormatter)
public class DateValueFormatter: NSObject, IAxisValueFormatter{
    
    var dates = [String] ()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        //return Formatter.editingString(dates)
        
        return dates[Int(value)]
    }
}
*/

class ChartViewController: UIViewController,ChartViewDelegate {
    
    @IBOutlet weak var chtChart: LineChartView!
    
    var systolic_data : [Double] = [] // systolic holder
    var bg_data : [Double] = [] // glucose holder
    var date_data : [String] = [] // dates from firebase
    var dateString : [String] = []// array to hold converted dateformats
    
    //high contrast mode
    @IBAction func clrSwitch(_ sender: UISwitch) {
        if  (sender.isOn == true){
            view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        else{
            view.backgroundColor = #colorLiteral(red: 1, green: 0.5490196078, blue: 0.5803921569, alpha: 1)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        read()
        // updateGraph()
        print("viewdidload b4")
        // setChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Generate graph button
    @IBAction func testbutt(_ sender: UIButton) {
        //updateGraph()
        print("before setChart is called after button")
        setChart()
        print("after setChart is called after button")
        
    }
    
    
    // retrive from firebase
    func read()
    {
        var ref: DatabaseReference!
        
        // Getting the current userID logged in
        let userID = Auth.auth().currentUser?.uid
        
        ref = Database.database().reference().child(userID!)
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            
            for log in snapshot.children.allObjects as![DataSnapshot]{
                let logObject = log.value as? [String: AnyObject]
                let logBloodGlucose = logObject?["bloodGlucose"]
                let logSystolicBP = logObject?["systolicBP"]
                let logDate = logObject?["date"]
                
                
                
                self.bg_data.append(logBloodGlucose as! Double)
                self.systolic_data.append(logSystolicBP as! Double)
                self.date_data.append(logDate as! String)
                
                print(self.bg_data)
                print(self.systolic_data)
                print(self.date_data)
                
                
            }
            let dateFormatter = DateFormatter()
            // let dateString: [String] = [String]()
            for i in self.date_data {
                dateFormatter.dateFormat = "mm/dd/yyyy HH:mm"
                let date_array = dateFormatter.date(from: i)
                dateFormatter.dateFormat = "HH ddMMM"
                let dateObj = dateFormatter.string(from: date_array!)
                self.dateString.append(dateObj)
            }
            print("1")
            print(self.dateString)

            
            
        }) { (err: Error) in
            print("\(err.localizedDescription)")
        }
    }
    

    
    // trying using setChart()
    func setChart(){
        print("setChart is called to see dateString again")
        print(dateString)
        print("see if dateString is empty")
        chtChart.setLineChartData(xValues: dateString, y1Values: systolic_data, y2Values: bg_data, label: "Glucose & Blood pressure level")
        
    }
}


extension LineChartView {
    
    private class LineChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        init(values: [String]) {
            super.init()
            self.labels = values
           // self.labels = labels
        }
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let val = Int(value)
            
            if val >= 0 && val < labels.count {
                
                return labels[Int(val)]
                
            }
            
            return ""
            // return labels[Int(value) % labels.count]
        }
        
        
 
    }
    
    func setLineChartData(xValues: [String], y1Values: [Double], y2Values: [Double], label: String) {
        
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        
        
        
        for i in 0..<y1Values.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: y1Values[i], data: xValues as AnyObject)
            dataEntries1.append(dataEntry1)
        }
        let systolic = LineChartDataSet(values: dataEntries1, label: "Blood Pressure")
        systolic.setCircleColors(.red)
        systolic.circleHoleColor = .red
        systolic.circleRadius = 3
        systolic.colors = ChartColorTemplates.joyful()
        //systolic.setColor(.red)
        systolic.valueTextColor = .red
        systolic.valueFont = UIFont(name: "Helvetica", size: 12.0)!
        
        for i in 0..<y2Values.count {
            let dataEntry2 = ChartDataEntry(x: Double(i), y: y2Values[i], data: xValues as AnyObject)
            dataEntries2.append(dataEntry2)
        }
        let bloodGlucose = LineChartDataSet(values: dataEntries2, label: "Blood Glucose")
        bloodGlucose.setCircleColors(.blue)
        bloodGlucose.circleHoleColor = .blue
        bloodGlucose.circleRadius = 3
        //bloodGlucose.setColor(.blue)
        bloodGlucose.colors = ChartColorTemplates.pastel()
        bloodGlucose.valueTextColor = .blue
        bloodGlucose.valueFont = UIFont(name: "Helvetica", size: 12.0)!
        
        let chartData : LineChartData = LineChartData(dataSets: [systolic, bloodGlucose])
        self.data = chartData
        
        //self.xAxis.valueFormatter = LineChartFormatter(values: xValues)
        let chartFormatter = LineChartFormatter(values: xValues)
        let xAxis = XAxis()
        
        self.backgroundColor = .gray
        self.chartDescription?.enabled = false
        self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBounce)
        
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.labelCount = xValues.count
        self.xAxis.labelPosition = .bottom
        self.xAxis.drawLabelsEnabled = true
        self.xAxis.enabled = true
        self.xAxis.granularityEnabled = true
        self.xAxis.granularity = 1
        self.xAxis.drawLimitLinesBehindDataEnabled = true
        self.rightAxis.enabled = false
        self.leftAxis.labelTextColor = .red
        self.xAxis.labelTextColor = .red
        
        let BP_target = ChartLimitLine(limit: 90.0, label: "Target Blood Pressure")
        
        self.leftAxis.addLimitLine(BP_target)
        let BG_target = ChartLimitLine(limit: 70.0, label: "Target Blood Glucose")
        self.leftAxis.addLimitLine(BG_target)
        
        //  let xAxis = XAxis()
     //   xAxis.valueFormatter = chartFormatter
        //self.xAxis.valueFormatter = xAxis.valueFormatter
    }
}
        /*
        var chartDataSet : [LineChartDataSet] = [LineChartDataSet]()
        chartDataSet.append(systolic)
        chartDataSet.append(bloodGlucose)
 */
        ////////////
        //let formatter: XAxisStringValueFormatter = XAxisStringValueFormatter(values: xValues)
       // let xaxis: XAxis = XAxis()
       // var dataEntries: [ChartDataEntry] = []
      //  for i in 0..<xValues.count {
        //    let dataEntry = ChartDataEntry(x: Double(i), y: yValues[i], data: xValues as AnyObject)
          //  dataEntries.append(dataEntry)
        //}
        //xaxis.valueFormatter = formatter
        
       // let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Price")
        
       // let data: LineChartData = LineChartData(dataSets: [lineChartDataSet])
  //      self.lineChartView.data = data
    //    self.lineChartView.xAxis.valueFormatter = xaxis.valueFormatter
 ///////////
        //let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
        //let chartData = LineChartData(dataSet: chartDataSet)
        
        


    /*
    func setChart(dataPoints: [String], values: [Double]) {
        
        // format date_data array into dateformatt
        var dateObjects = [Date]()
        let dateFormatter = DateFormatter()
        for date in date_data{
            dateFormatter.dateFormat = "mm/dd/yyyy HH:mm"
            let dateObject = dateFormatter.date(from: date)
            dateObjects.append(dateObject!)
        }
        
        var lineChartEntry = [ChartDataEntry]() //array to be displayed - insulin
        for i in 0..<systolic_data.count {
            
            let systolic_value = ChartDataEntry(x: Double(i), y: systolic_data[i]) // set x and y
            lineChartEntry.append(systolic_value) // here to add data set
        }
        let systolic = LineChartDataSet(values: lineChartEntry, label: "Blood Pressure") // convert lineChartEntry to a LineChartDataSet for insulin data sets
        systolic.setColor(UIColor.blue) // set to blue
        systolic.setCircleColor(UIColor.blue)
        
        
        // BG datasets
        var lineChartEntry1 = [ChartDataEntry]() // blood glucose
        for i in 0..<bg_data.count {
            let bg_value = ChartDataEntry(x: Double(i), y: bg_data[i]) // set x and y
            lineChartEntry1.append(bg_value) // here to add data set
        }
        let bloodGlucose = LineChartDataSet(values: lineChartEntry1, label: "Blood Glucose") // convert lineChartEntry to a LineChartDataSet for insulin data sets
        bloodGlucose.setColor(UIColor.cyan) // set to cyan
        
        // concat BP and BG datasets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(systolic)
        dataSets.append(bloodGlucose)
        
        // let data : LineChartData = LineChartData(dataSets: dataSets)
        let lineChartData = LineChartData(dataSet: [dataSets])

        self.chtChart.data = lineChartData
        chtChart.chartDescription?.text = "Glucose & Blood pressure level" // graph description
    }
}
*/
/*
    // updating the graph viewer with the new data entries
    func updateGraph(){
        // BP datasets
        var lineChartEntry = [ChartDataEntry]() //array to be displayed - insulin
        for i in 0..<systolic_data.count {
            
            let systolic_value = ChartDataEntry(x: Double(i), y: systolic_data[i]) // set x and y
            lineChartEntry.append(systolic_value) // here to add data set
        }
        let systolic = LineChartDataSet(values: lineChartEntry, label: "Blood Pressure") // convert lineChartEntry to a LineChartDataSet for insulin data sets
        systolic.setColor(UIColor.blue) // set to blue
        systolic.setCircleColor(UIColor.blue)
        
        
        // BG datasets
        var lineChartEntry1 = [ChartDataEntry]() // blood glucose
        for i in 0..<bg_data.count {
            let bg_value = ChartDataEntry(x: Double(i), y: bg_data[i]) // set x and y
            lineChartEntry1.append(bg_value) // here to add data set
        }
        let bloodGlucose = LineChartDataSet(values: lineChartEntry1, label: "Blood Glucose") // convert lineChartEntry to a LineChartDataSet for insulin data sets
        bloodGlucose.setColor(UIColor.cyan) // set to cyan

        // concat BP and BG datasets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(systolic)
        dataSets.append(bloodGlucose)
        
        let data : LineChartData = LineChartData(dataSets: dataSets)
        
        // dates are in date_data array
        //dateFormatter.dateStyle = .short
        
        
        chtChart.xAxis.valueFormatter = DateValueFormatter()

        

        
        
        
        // let dateString = dateFormatter.date(from: date_data)
        // dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as TimeZone!
        
        
        
        self.chtChart.data = data
        
        chtChart.chartDescription?.text = "Glucose & Blood pressure level" // graph description
    }
 */


/*
 // MARK: - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
