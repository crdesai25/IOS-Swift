Documentation for AccuraSDK IOS Project
1. FOR Display List
    
        i. Add ListViewcontroller(.h .m) files in your project and take its view from MainStoryboard_iPhone.storyboard 

2. FOR Passport & ID MRZ setup 

        i. SDK with sample project is already setup and can be used directly.
        ii. Import key.license file in AccuraScan folder(codescan -> accura scan). Don’t remove it
        iii. Change Bundle Id with your Bundle ID.
        iv. Integrating Passport & ID MRZ setup into another project
            -  Copy and drag/drop AccuraScan folder in your project (Do not rename file names in it)
            -  Goto Build Phases/Link Binary with Libraries and import opencv2.framework 
            -  One important point is key.license file. You need to import key.license file in AccuraSDK folder. That file is assigned with your registered bundle id with AccuraScan.

3.  FOR USA Driving License & Barcode PDF 417 

        i. SDK with sample project is already setup and can be used directly.
        ii. Integrating USA Driving License & Barcode PDF 417 into another project
            -  Copy and drag/drop uiview, storyboard, utils, controller folder to your project file 
        iii. Default type for USA Driving Licence is PDF 417.so PDF 417 type DL is supported.

4. FOR Aadhaar card India 

        i. SDK with sample project is already setup and can be used directly.
        ii. Change in api_key value in WebAPIRequest.m file which given from Accura scan.
            for ex.([dictdata setObject:@"4536913354JeLmrL98Xw9vVslx3BOvA4cBKmVZh7U4BDJeFoFeG" forKey:@"api_key"];)
        iii. Integrating Aadhaar card India into another project
            - Copy and drag/drop   ScanAdharCard and its file and take view from MainStoryboard_iPhone.storyboard and add to your project 
            - Copy and drag/drop CardResultViewController (.h .m file)and ImageViewController
                (.h .m file) take view from MainStoryboard_iPhone.storyboard and add to your project 

5. FOR Pan card India 

        i. SDK with sample project is already setup and can be used directly.
        ii. Change in api_key value in WebAPIRequest.m file which given from Accura scan.
            for ex.([dictdata setObject:@"4536913354JeLmrL98Xw9vVslx3BOvA4cBKmVZh7U4BDJeFoFeG" forKey:@"api_key"];).
        iii. Integrating Pan card India into another project
            - Copy and drag/drop PlacePanCardViewController
                and its file and take view from MainStoryboard_iPhone.storyboard and add to your project.
            - Copy and drag/drop CardResultViewController (.h .m file)and ImageViewController
            (.h .m file) take view from MainStoryboard_iPhone.storyboard and add to your project.
            
6. Folder description 
        
        i.CodeScan->AccuraScan(folder) = Use for Passport & ID MRZ setup 
        ii.CodeScan->ScanPanCard(folder) = Use for Pan card India 
        iii.CodeScan->ScanAdharCard(folder) = Use For Aadhar card India
        iv.CodeScan->UIView(folder)
           CodeScan->StoryBoards(folder)
           CodeScan->Utils(folder)
           CodeScan->Controller(folder) = Use For BarCode
           CodeScan->UIView(folder)->Resultpdf417 file = Use For PDF417 result


