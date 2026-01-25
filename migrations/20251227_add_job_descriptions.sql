-- Add job_description column to cse_profiles
-- This allows ChaSen to understand each team member's responsibilities

ALTER TABLE cse_profiles ADD COLUMN IF NOT EXISTS job_description TEXT;

-- Populate job descriptions for each role
UPDATE cse_profiles SET job_description = 'Executive Vice President responsible for overall APAC business strategy, P&L ownership, and regional leadership. Oversees all functional areas including Sales, Client Success, Solutions, and Support.' WHERE role = 'EVP APAC';

UPDATE cse_profiles SET job_description = 'Leads the Client Success team across APAC, driving customer retention, satisfaction, and growth. Manages CSE team performance, develops success strategies, and serves as executive sponsor for key accounts.' WHERE role = 'AVP Client Success, APAC';

UPDATE cse_profiles SET job_description = 'Oversees business operations, project delivery, and support functions. Ensures operational excellence and coordinates cross-functional initiatives.' WHERE role = 'VP Business Support';

UPDATE cse_profiles SET job_description = 'Leads pre-sales and solutions consulting, working with prospects and clients to design optimal Altera solutions. Manages clinical and technical consulting resources.' WHERE role = 'VP Solutions';

-- Note: CSE focuses on commercial aspects, CAM focuses on relationship management (corrected 2026-01-25)
UPDATE cse_profiles SET job_description = 'Manages commercial aspects of client relationships including contract renewals, upsells, and account growth opportunities. Works closely with CAMs on account strategy.' WHERE role = 'Client Success Executive';
UPDATE cse_profiles SET job_description = 'Manages commercial aspects of client relationships including contract renewals, upsells, and account growth opportunities. Works closely with CAMs on account strategy.' WHERE role = 'CSE';

UPDATE cse_profiles SET job_description = 'Primary client relationship owner responsible for client health, satisfaction, and retention. Conducts regular check-ins, coordinates support issues, and drives adoption of Altera solutions.' WHERE role = 'Client Account Manager';
UPDATE cse_profiles SET job_description = 'Primary client relationship owner responsible for client health, satisfaction, and retention. Conducts regular check-ins, coordinates support issues, and drives adoption of Altera solutions.' WHERE role = 'CAM';

UPDATE cse_profiles SET job_description = 'Senior solutions consultant providing technical and clinical expertise for complex implementations and strategic accounts.' WHERE role = 'Director Solutions';

UPDATE cse_profiles SET job_description = 'Provides clinical leadership and healthcare industry expertise. Advises on product direction, clinical workflows, and healthcare regulations.' WHERE role = 'Chief Medical Officer';

UPDATE cse_profiles SET job_description = 'Manages client implementation projects, coordinating resources, timelines, and deliverables. Ensures successful go-lives and client satisfaction.' WHERE role = 'Project Manager';

UPDATE cse_profiles SET job_description = 'Leads the support organisation, ensuring timely resolution of client issues and maintaining high service levels.' WHERE role = 'AVP Support';

UPDATE cse_profiles SET job_description = 'Supports operational processes, reporting, and administrative functions for the APAC team.' WHERE role = 'Business Operations';

UPDATE cse_profiles SET job_description = 'Develops and executes regional marketing campaigns, events, and demand generation activities.' WHERE role = 'Sr Field Marketing, APAC';

UPDATE cse_profiles SET job_description = 'Partners with APAC leadership on talent management, employee engagement, and HR initiatives.' WHERE role = 'Sr HR Business Partner';

UPDATE cse_profiles SET job_description = 'Oversees all Altera operations within assigned country, managing local teams and client relationships.' WHERE role = 'Country Manager';

UPDATE cse_profiles SET job_description = 'Global leader for Client Success and Operations, setting strategy and best practices across all regions.' WHERE role = 'SVP Client Success & Operations';

UPDATE cse_profiles SET job_description = 'Leads global Client Success initiatives, driving methodology, tools, and team development.' WHERE role = 'VP Client Success';

UPDATE cse_profiles SET job_description = 'Manages marketing programs and campaigns, coordinating with regional teams on content and messaging.' WHERE role = 'Marketing Manager';

UPDATE cse_profiles SET job_description = 'Manages program delivery and implementation coordination across the APAC region.' WHERE role = 'AVP Program Delivery';
