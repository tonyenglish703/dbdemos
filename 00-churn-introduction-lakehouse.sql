-- Databricks notebook source
-- MAGIC %md-sandbox
-- MAGIC # Intelligence Data Platform for retail - Reducing Churn with a Customer 360 platform
-- MAGIC
-- MAGIC <img src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn.png" style="float: left; margin-right: 30px" width="600px" />
-- MAGIC
-- MAGIC <br/>
-- MAGIC
-- MAGIC ## What is The Databricks Intelligence Data Platform for retail?
-- MAGIC
-- MAGIC It's the only enterprise data platform that allows you to leverage all your data, from any source, on any workload to always offer more engaging customer experiences driven by real time data, at the lowest cost. 
-- MAGIC
-- MAGIC The Databricks Intelligence Data Platform for Retail unified analytics and AI capabilities allow you to achieve personalized engagement, employee productivity, and operational speed and efficiency at a scale never before possible - the foundation for future-proof retail transformation and the data-defined enterprise.
-- MAGIC
-- MAGIC
-- MAGIC ### Simple
-- MAGIC   One single platform and governance/security layer for your data warehousing and AI to **accelerate innovation** and **reduce risks**. No need to stitch together multiple solutions with disparate governance and high complexity.
-- MAGIC
-- MAGIC ### Open
-- MAGIC   Built on open source and open standards. You own your data and prevent vendor lock-in, with easy integration with external solution. Being open also lets you share your data with any external organization, regardless of their data stack/vendor.
-- MAGIC
-- MAGIC ### Multicloud
-- MAGIC   One consistent data platform across clouds. Process your data where your need.
-- MAGIC  
-- MAGIC <!-- Collect usage data (view). Remove it to disable collection or disable tracker during installation. View README for more details.  -->
-- MAGIC <img width="1px" src="https://ppxrzfxige.execute-api.us-west-2.amazonaws.com/v1/analytics?category=lakehouse&org_id=1444828305810485&notebook=%2F00-churn-introduction-lakehouse&demo_name=lakehouse-retail-c360&event=VIEW&path=%2F_dbdemos%2Flakehouse%2Flakehouse-retail-c360%2F00-churn-introduction-lakehouse&version=1">

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Demo: build a c360 database and reduce customer churn with Databricks Intelligence Data Platform.
-- MAGIC
-- MAGIC In this demo, we'll step in the shoes of a retail company selling goods with a recurring business.
-- MAGIC
-- MAGIC The business has determined that the focus must be placed on churn. We're asked to:
-- MAGIC
-- MAGIC * Analyse and explain current customer churn: quantify churn, trends and the impact for the business
-- MAGIC * Build a proactive system to forecast and reduce churn by taking automated action: targeted email, phoning etc.
-- MAGIC
-- MAGIC
-- MAGIC ### What we'll build
-- MAGIC
-- MAGIC To do so, we'll build an end-to-end solution with the Lakehouse. To be able to properly analyse and predict our customer churn, we need information coming from different external systems: Customer profiles coming from our website, order details from our ERP system and mobile application clickstream to analyse our customers activity.
-- MAGIC
-- MAGIC At a very high level, this is the flow we'll implement:
-- MAGIC
-- MAGIC <img width="1000px" src="https://github.com/databricks-demos/dbdemos-resources/raw/main/images/retail/lakehouse-churn/lakehouse-retail-c360-churn-0.png" />
-- MAGIC
-- MAGIC 1. Ingest and create our c360 database, with tables easy to query in SQL
-- MAGIC 2. Secure data and grant read access to the Data Analyst and Data Science teams.
-- MAGIC 3. Run BI queries to analyse existing churn
-- MAGIC 4. Build ML model to predict which customer is going to churn and why
-- MAGIC
-- MAGIC As a result, we'll have all the information required to trigger custom actions to increase retention (email personalized, special offers, phone call...)
-- MAGIC
-- MAGIC ### Our dataset
-- MAGIC
-- MAGIC To simplify this demo, we'll consider that an external system is periodically sending data into our blob storage (S3/ADLS/GCS):
-- MAGIC
-- MAGIC - Customer profile data *(name, age, address etc)*
-- MAGIC - Orders history *(what our customer bought over time)*
-- MAGIC - Events from our application *(when was the last time customers used the application, clicks, typically in streaming)*
-- MAGIC
-- MAGIC *Note that at a technical level, our data could come from any source. Databricks can ingest data from any system (SalesForce, Fivetran, queuing message like kafka, blob storage, SQL & NoSQL databases...).*
-- MAGIC
-- MAGIC Let's see how this data can be used within the Intelligence Data Platform to analyse and reduce our customer churn!  

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC ## 1/ Ingesting and preparing the data (Data Engineering)
-- MAGIC
-- MAGIC <img style="float: left; margin-right: 20px" width="400px" src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn-2.png" />
-- MAGIC
-- MAGIC
-- MAGIC <br/>
-- MAGIC <div style="padding-left: 420px">
-- MAGIC Our first step is to ingest and clean the raw data we received so that our Data Analyst team can start running analysis on top of it.
-- MAGIC
-- MAGIC
-- MAGIC <img src="https://pages.databricks.com/rs/094-YMS-629/images/delta-lake-logo.png" style="float: right; margin-top: 20px" width="200px">
-- MAGIC
-- MAGIC ### Delta Lake
-- MAGIC
-- MAGIC All the tables we'll create in the Lakehouse will be stored as Delta Lake table. [Delta Lake](https://delta.io) is an open storage framework for reliability and performance. <br/>
-- MAGIC It provides many functionalities *(ACID Transaction, DELETE/UPDATE/MERGE, Clone zero copy, Change data Capture...)* <br />
-- MAGIC For more details on Delta Lake, run `dbdemos.install('delta-lake')`
-- MAGIC
-- MAGIC ### Simplify ingestion with Delta Live Tables (DLT)
-- MAGIC
-- MAGIC Databricks simplifies data ingestion and transformation with Delta Live Tables by allowing SQL users to create advanced pipelines, in batch or streaming. The engine will simplify pipeline deployment and testing and reduce operational complexity, so that you can focus on your business transformation and ensure data quality.<br/>

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC Open the customer churn 
-- MAGIC   <a dbdemos-pipeline-id="dlt-churn" href="#joblist/pipelines/2ab11eb6-cfa1-4d2b-9c4f-8ef57c2bdabb" target="_blank">Delta Live Table pipeline</a> or the [SQL notebook]($./01-Data-ingestion/01.1-DLT-churn-SQL) *(Alternatives: [DLT Python version]($./01-Data-ingestion/01.3-DLT-churn-python) - [plain Delta+Spark version]($./01-Data-ingestion/plain-spark-delta-pipeline/01.5-Delta-pipeline-spark-churn))*. <br>
-- MAGIC   For more details on DLT: `dbdemos.install('dlt-load')` or `dbdemos.install('dlt-cdc')`

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC ## 2/ Securing data & governance (Unity Catalog)
-- MAGIC
-- MAGIC <img style="float: left" width="400px" src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn-6.png" />
-- MAGIC
-- MAGIC <br/><br/><br/>
-- MAGIC <div style="padding-left: 420px">
-- MAGIC   Now that our first tables have been created, we need to grant our Data Analyst team READ access to be able to start alayzing our Customer churn information.
-- MAGIC   
-- MAGIC   Let's see how Unity Catalog provides Security & governance across our data assets with, including data lineage and audit log.
-- MAGIC   
-- MAGIC   Note that Unity Catalog integrates Delta Sharing, an open protocol to share your data with any external organization, regardless of their stack. For more details:  `dbdemos.install('delta-sharing-airlines')`
-- MAGIC  </div>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC    Open [Unity Catalog notebook]($./02-Data-governance/02-UC-data-governance-security-churn) to see how to setup ACL and explore lineage with the Data Explorer.
-- MAGIC   

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC ## 3/ Analysing churn analysis  (BI / Data warehousing / SQL) 
-- MAGIC
-- MAGIC <img width="300px" src="https://github.com/databricks-demos/dbdemos-resources/blob/main/images/retail/lakehouse-churn/lakehouse-retail-c360-dashboard-churn.png?raw=true"  style="float: right; margin: 100px 0px 10px 10px;"/>
-- MAGIC
-- MAGIC
-- MAGIC
-- MAGIC <img width="400px" src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn-3.png"  style="float: left; margin-right: 10px"/>
-- MAGIC  
-- MAGIC <br><br><br>
-- MAGIC Our datasets are now properly ingested, secured, with a high quality and easily discoverable within our organization.
-- MAGIC
-- MAGIC Data Analysts are now ready to run BI interactive queries, with low latencies & high throughput, including Serverless Data Warehouses providing instant stop & start.
-- MAGIC
-- MAGIC Let's see how we Data Warehousing can done using Databricks, including with external BI solutions like PowerBI, Tableau and other!

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC Open the [Data Warehousing notebook]($./03-BI-data-warehousing/03-BI-Datawarehousing) to start running your BI queries or access or directly open the <a dbdemos-dashboard-id="churn-universal" href='/sql/dashboardsv3/01ef54d7f4f71c489e7c7f773f81fb58' target="_blank">Churn Analysis Dashboard</a>

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC ## 4/ Predict churn with Data Science & Auto-ML
-- MAGIC
-- MAGIC <img width="400px" style="float: left; margin-right: 10px" src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn-4.png" />
-- MAGIC
-- MAGIC <br><br><br>
-- MAGIC Being able to run analysis on our past data already gave us a lot of insight to drive our business. We can better understand which customers are churning to evaluate the impact of churn.
-- MAGIC
-- MAGIC However, knowing that we have churn isn't enough. We now need to take it to the next level and build a predictive model to determine our customers at risk of churn and increase our revenue.
-- MAGIC
-- MAGIC This is where the Intelligence Data Platform value comes in. Within the same platform, anyone can start building ML model to run such analysis, including low code solution with AutoML.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Let's see how to train an ML model within 1 click with the [04.1-automl-churn-prediction notebook]($./04-Data-Science-ML/04.1-automl-churn-prediction)
-- MAGIC
-- MAGIC #### Reducing churn leveraging Databricks GenAI and LLMs capabilities 
-- MAGIC
-- MAGIC GenAI provides unique capabilities to improve your customer relationship, providing better services but also better analyzing your churn risk.
-- MAGIC
-- MAGIC Databricks provides built-in GenAI capabilities for you to accelerate such GenAI apps deployment. 
-- MAGIC
-- MAGIC Discover how with the [04.4-GenAI-for-churn]($./04-Data-Science-ML/04.4-GenAI-for-churn) Notebook.

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC
-- MAGIC ## Automate action to reduce churn based on predictions
-- MAGIC
-- MAGIC
-- MAGIC <img style="float: right" width="400px" src="https://github.com/databricks-demos/dbdemos-resources/blob/main/images/retail/lakehouse-churn/lakehouse-retail-c360-dashboard-churn-prediction.png?raw=true">
-- MAGIC
-- MAGIC We now have an end-to-end data pipeline analizing and predicting churn. We can now easily trigger actions to reduce the churn based on our business:
-- MAGIC
-- MAGIC - Send targeting email campaigns to the customers that are most likely to churn
-- MAGIC - Phone campaign to discuss with our customers and understand what's going on
-- MAGIC - Understand what's wrong with our line of product and fix it
-- MAGIC
-- MAGIC These actions are out of the scope of this demo and simply leverage the Churn prediction field from our ML model.
-- MAGIC
-- MAGIC ## Track churn impact over the next month and campaign impact
-- MAGIC
-- MAGIC Of course, this churn prediction can be re-used in our dashboard to analyse future churn and measure churn reduction. 
-- MAGIC
-- MAGIC The pipeline created with the Lakehouse will offer a strong ROI: it took us a few hours to set up this pipeline end-to-end and we have potential gain of $129,914 / month!

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC Open the <a dbdemos-dashboard-id="churn-prediction" href='/sql/dashboardsv3/01ef54d7f4f71c489e7c7f773f81fb58' target="_blank">Churn prediction DBSQL dashboard</a> to have a complete view of your business, including churn prediction and proactive analysis.

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC ## 5/ Deploying and orchestrating the full workflow
-- MAGIC
-- MAGIC <img style="float: left; margin-right: 10px" width="400px" src="https://raw.githubusercontent.com/QuentinAmbard/databricks-demo/main/retail/resources/images/lakehouse-retail/lakehouse-retail-churn-5.png" />
-- MAGIC
-- MAGIC <br><br><br>
-- MAGIC While our data pipeline is almost completed, we're missing one last step: orchestrating the full workflow in production.
-- MAGIC
-- MAGIC With Databricks Lakehouse, no need to manage an external orchestrator to run your job. Databricks Workflows simplifies all your jobs, with advanced alerting, monitoring, branching options etc.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Open the [workflow and orchestration notebook]($./05-Workflow-orchestration/05-Workflow-orchestration-churn) to schedule our pipeline (data ingetion, model re-training etc)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Conclusion
-- MAGIC
-- MAGIC We demonstrated how to implement an end-to-end pipeline with the Intelligence Data Platform, using a single, unified and secured platform:
-- MAGIC
-- MAGIC - Data ingestion
-- MAGIC - Data analysis / DW / BI 
-- MAGIC - Data science / ML
-- MAGIC - AI and GenAI app
-- MAGIC - Workflow & orchestration
-- MAGIC
-- MAGIC As result, our analyst team was able to simply build a system to not only understand but also forecast future churn and take action accordingly.
-- MAGIC
-- MAGIC This was only an introduction to the Databricks Intelligence Data Platform. For more details, contact your account team and explore more demos with `dbdemos.list()`
