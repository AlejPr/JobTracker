*Currently a work in progress*

## What's this application?
JobTracker (placeholder name) is a macOS application that assists in recording and analyzing data from a user's job search.

## Why?
During my job search I found myself wanting to keep track of all the listings I've applied to. I also became curious about analytics - how many jobs I've applied to, my rejection rate, and so forth.

I started off using an excel spreadsheet, but then I quickly came across an issue - companies take down listings all the time. So keeping a link to a job listing isn't enough. Additionally, recording all of the data from each listing can be very time consuming and tedious.

## What does this application do?
JobTracker simplifies record keeping. Give the application a link and it will read the website, record relevant information from the listing, and save an offline copy of the webpage for future reference. 

At the moment that's all it does. I plan to add data analysis tools to visualize my job search and calculate statistics.

## How?
I'm using ChatGPT 5.2 nano to filter webpage content. The application is built using SwiftUI and MVVM architecture. Using Apple's WKWebView class, it's possible to load pages inside of the application and convert them to text. The text is then fed to GPT nano which parses relevant data from the webpage and returns it as a JSON object. WKWebView also supports saving to PDFs.

## Demo

https://github.com/user-attachments/assets/f01005ae-b3ed-4796-871c-98baa40dd677
