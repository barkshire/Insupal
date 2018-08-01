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
    var dateString : [String]! // array to hold converted dateformats
    
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            var dateString: [String] = [String]()
            for i in self.date_data {
                dateFormatter.dateFormat = "mm/dd/yyyy HH:mm"
                let date_array = dateFormatter.date(from: i)
                dateFormatter.dateFormat = "dd hh:mm"
                let dateObj = dateFormatter.string(from: date_array!)
                dateString.append(dateObj)
            }
            print(dateString)

            
        }) { (err: Error) in
            
            print("\(err.localizedDescription)")
            
        }
        
    }
    
    // Generate graph button
    @IBAction func testbutt(_ sender: UIButton) {
         //updateGraph()
        setChart()
    }
    
    // trying using setChart()
    func setChart(){
        // let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        
        
        //let unitsSold = [20.0, 4.0, 3.0, 6.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        chtChart.setLineChartData(xValues: dateString, y1Values: systolic_data, y2Values: bg_data, label: "Glucose & Blood pressure level")
    }
}
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


extension LineChartView {
    
    private class LineChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setLineChartData(xValues: [String], y1Values: [Double], y2Values: [Double], label: String) {
        
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        
        for i in 0..<y1Values.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: y1Values[i])
            dataEntries1.append(dataEntry1)
        }
        let systolic = LineChartDataSet(values: dataEntries1, label: "Blood Pressure")
        
        for i in 0..<y2Values.count {
            let dataEntry2 = ChartDataEntry(x: Double(i), y: y2Values[i])
            dataEntries2.append(dataEntry2)
        }
        let bloodGlucose = LineChartDataSet(values: dataEntries2, label: "Blood Glucose")
        
        var chartDataSet : [LineChartDataSet] = [LineChartDataSet]()
        chartDataSet.append(systolic)
        chartDataSet.append(bloodGlucose)
        
        //let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
        //let chartData = LineChartData(dataSet: chartDataSet)
        let chartData : LineChartData = LineChartData(dataSets: chartDataSet)
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        
        self.data = chartData
    }
}

/*
 // MARK: - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
