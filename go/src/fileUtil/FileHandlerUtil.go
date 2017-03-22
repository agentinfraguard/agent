
// /home/piyush/.go/src

package fileUtil
import (
    
    "fmt"
    "io/ioutil"
    "os"
    _ "fmt" // for unused variable issue
 
    "log"
    "strings"
    //"stringUtil"
    
  
)



 const logFilePath = "/var/logs/infraguard/activityLog"   
func IsFileExisted(filePath string) (bool) {
   _, err := os.Stat(filePath)
    if err != nil {
        if os.IsNotExist(err) {
            return false;
        }
    }
    return true;
}


/*
   Read any type of file. If isAbortOnError = true and error occur, then
   further execution stop. 

   It returns data in String even in case of error if 'isAbortOnError' = false.
   Note :- This method does not check whether FILE EXIST OR NOT. In that case, it may
   also returns empty string.
*/
func ReadFile(filePath string, isAbortOnError bool) (string) {
     data, err := ioutil.ReadFile(filePath)
    if err != nil {
        fmt.Println("errorMsg = : ", err.Error()) 
        if(isAbortOnError){
            panic(err)    
        }else{
            return "";
        }
    }
    return string(data)
}

/*
 Below method REPLACES new contents if file already exists.
 If 'forceCreate' is false and file does not existed beforehand, then this method
 simply retuns to caller else file is created and data will write.
 
 This method will abort if error occur while writing data.

 Note :- It is up to the caller to ensure the data which is going to write is in good format and meaningful. 
*/
func WriteIntoFile(filePath string, dataToWrite string, forceCreate bool ){
   var err error
  if(IsFileExisted(filePath) == false){
    if(forceCreate == true){
       _, err := os.Create(filePath)
      if err != nil {
      errorMsg := " Error While writing into file at = : "+filePath +" Msg = : "+err.Error()
      WriteIntoLogFile(errorMsg, "sudo")
      panic(err)
     }
    }else{
      return
    }
 }
 err = ioutil.WriteFile(filePath, []byte(dataToWrite),0644)
  if err != nil {
      errorMsg := " Error While writing into file at = : "+filePath +" Msg = : "+err.Error()
      WriteIntoLogFile(errorMsg, "sudo")
  }
}


func WriteIntoLogFile(msg, sudo string) {
  f, err := os.OpenFile(logFilePath, os.O_RDWR | os.O_CREATE | os.O_APPEND, 0666)
  if err != nil {
    log.Fatalf("error opening file : ", err.Error())

  }

  defer f.Close()
  log.SetOutput(f)
  msg = strings.Replace(msg, "\n","",-1)
  log.Println(msg)


}

