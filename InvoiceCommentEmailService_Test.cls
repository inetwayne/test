@istest  
public class InvoiceCommentEmailService_Test 
{  
    static testMethod void testMe() 
    {
        
        //InvoiceDefaults__c idef = InvoiceDefaults__c.getorgDefaults();  
        InvoiceDefaults__c idef = new InvoiceDefaults__c();
        idef.Days_between_Reminders__c = 10;
        idef.Initial_Invoice_Email_Template__c = '00XJ0000000O76X';
        idef.Reminder_Invoice_Email_Template__c = '00XJ0000000O76c';
        insert idef;

        system.debug('_____ idef___' + idef);

        ProjectDateSettings__c pds = new ProjectDateSettings__c();
        pds.BuildConfigTestingEndDayIncrement__c = 14;
        pds.BuildConfigTestingStartDayIncrement__c = 15 ;
        pds.DesignDiscoveryEndDaysIncrement__c = -1;
        pds.GoLiveAndPostGoLiveEndDayIncrement__c =7;
        pds.NonImplementationEndDateIncrement__c = 30;
        insert pds;

        system.debug('____pds____' + pds);

        UserLicense UL =[select id,LicenseDefinitionKey,name from userlicense where name='Salesforce' limit 1];
        Profile p = [Select Id FROM Profile WHERE Name = 'System Administrator' and  UserLicense.id = :UL.id  LIMIT 1]; 

        User newUser = new User(

        profileId = p.id, 
        username = 'invCommentEmailTest@torque.com', 
        email = 'pb@ff.com', 
        emailencodingkey = 'UTF-8', 
        localesidkey = 'en_US', 
        languagelocalekey = 'en_US', 
        timezonesidkey = 'America/Los_Angeles', 
        alias='nusers', 
        lastname='lastname');        

        insert newUser;   
        system.debug('__newuser__'+newuser);

        //cretae Account...
        Account acc = new Account();
        acc.Type = 'End User - prospect';
        acc.Name = 'TestAcc';
        acc.Practice__c = 'Other';
        insert acc;
        system.debug('__acc__'+acc);

        //Create Contact..
        Contact con = new Contact();
        con.LastName= 'TestCon';
        con.AccountId = acc.Id;
        // con.SFDC_User_ID__c = newUser.id;
        // con.Sfdc_User__c = newUser.id;
        insert con;  
        system.debug('__con__'+con);

        // system.debug('____pds.DesignDiscoveryEndDaysIncrement___' + pds.DesignDiscoveryEndDaysIncrement__c.intValue());
        system.debug('____pds.DesignDiscoveryEndDaysIncrement22___' + pds.DesignDiscoveryEndDaysIncrement__c);

        //Create Project for Email
        Project__c pro = new Project__c();
        pro.name = 'Email Project test';
        pro.Account__c = acc.id;
        pro.Status__c = 'Planning';
        pro.Go_Live_Date__c = date.today().addDays(25);
        pro.Status__c = 'Active';
        pro.Hourly_Rate__c = 20.0;
        pro.Project_Budgeted_Hrs__c = 160.0;
        pro.Kickoff__c = date.today().addDays(-30);
        pro.Go_Live_Date__c = date.newInstance(2015, 03, 25);
        //pro.sendToCashBoard__c = true;
        pro.Current_State__c = 'On Track';
        Insert pro;
        system.debug('__pro__'+pro);


        //Create Project Phase
        Project_Phase__c pphs = new Project_Phase__c();
        pphs.Phase_name__c = 'Design/Discovery';
        pphs.Start_Date__c = pro.Kickoff__c;
        pphs.End_Date__c = pro.Kickoff__c.addDays(14);
        pphs.Project__c = pro.id;
        insert pphs;
        system.debug('__pphs__'+pphs);

        //Create Invoice
        Invoice__c inv = new Invoice__c();
        inv.Account__c = acc.id;
        inv.Send_Reminders__c = true;
        inv.Payment_Status__c = 'open';
        //inv.Project__c = pro.id;
        inv.Next_Reminder_Date__c = Date.Today().addDays(-1);
        inv.Customer_Emails__c = 'yrgopal2001@gmail.com,yrgopal2002@gmail.com';
        insert inv;

        system.debug('__inv__'+inv);


        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = 'Test Job Applicant - Ref:'+inv.id;
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'someaddress@email.com';

        Invoice_comment__c invcom = new Invoice_comment__c();
        email.plainTextBody = '{' + invcom.id + '}';

        // add a Text attachment
        Messaging.InboundEmail.textAttachment Tattachment = new Messaging.InboundEmail.textAttachment();

        Tattachment.body = 'my attachment text';
        Tattachment.fileName = 'textfile.txt';
        Tattachment.mimeTypeSubType = 'text/plain';

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();

        attachment.body = blob.valueOf('my binary attachment text');
        attachment.fileName = 'binaryfile.txt';
        attachment.mimeTypeSubType = 'text/plain';

        email.textAttachments =
        new Messaging.inboundEmail.textAttachment[] { Tattachment };

        email.binaryAttachments =
        new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        // call the email service class and test it with the data in the testMethod
        InvoiceCommentEmailService emailProcess = new InvoiceCommentEmailService();
        emailProcess.handleInboundEmail(email, env);
    }
}