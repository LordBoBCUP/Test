#!/usr/bin/env node

const chalk = require('chalk');
const clear = require('clear');
const figlet = require('figlet');
const path = require('path');
const program = require('commander');
import fs from 'fs';
import { callbackify } from 'util';

const urlSuffix = '.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.json';
let x: number[] = new Array();
let totalRam: number = 0;
let totalCores: number = 0;
let d = Object;

clear();
console.log(
    chalk.red(
        figlet.textSync('ec2-calc', { horizontalLayout: 'full' })
    )
);

program
    .version('0.0.1')
    .description("A CLI to suggest the correct EC2 instance types for your virtualisation project")
    .option('-R, --region <string>', 'AWS Region e.g us-west-2')
    .option('-r, --reserved-cpu <n>', 'Reserved CPU in mCPU')
    .option('-s, --reserved-ram <n>', 'Reserved Memory in MB')
    .option('-c, --cpu <n>', 'CPU per VM in mCPU')
    .option('-m, --ram <n>', 'Memory Per VM in MB')
    .option('-n, --number <n>', 'Number Of VMs')
    .parse(process.argv);

console.log('your parameters were:');
if (program.region) console.log('  - Region');
if (program.reservedCpu) console.log('  - ReservedCPU');
if (program.reservedRam) console.log('  - ReservedRAM');
if (program.cpu) console.log('  - CPU');
if (program.ram) console.log('  - RAM');
if (program.number) console.log('  - Number');

if (!process.argv.slice(2).length) {
    program.outputHelp();
}

function calculateRequirements(cpu: number, ram: number, count: number, reservedRam: number, reservedCPU: number): void {
    for (let i = 0; i < arguments.length; i++) {
        console.log(arguments[i]);
    }
    totalRam = (ram * count) / 1024 + reservedRam / 1024;
    totalCores = Math.round(((cpu / 1000) * count) + (reservedCPU / 1000));
    console.log(totalRam);
    console.log(totalCores);
}

function exportResults(data: any, resultArray: Array<string>): void {
    for (let i = 0; i < 3; i++) {
        console.log(data.find((y: any) => y.SKU == resultArray[i]).SKU);
        console.log(data.find((y: any) => y.SKU == resultArray[i]).vCPU);
        console.log(data.find((y: any) => y.SKU == resultArray[i]).Memory);
    }

    // create new objects

    // 
}

function ProcessResults(data: any) {
    let count = 0;
    let resultArray = new Array<string>();
    for (let i = 0; i < data.length; i++) {
        let temp: string = String(data[i]['Memory']);
        let memory: number = parseInt(temp.replace(/[^\d]/g, ''));
        let vCPU: number = parseInt(data[i]['vCPU'].replace(/[^\d]/g, ''));
        let termType: string = data[i]['TermType']
        let os: string = data[i]['Operating System']
        if (totalRam > memory && totalCores > vCPU && termType == 'OnDemand' && os == 'Linux') {
            resultArray.push(data[i]['SKU']);
            // console.log(i);
            // console.log(data[i]);
            // console.log(data[i]['SKU']);
            // console.log(data[i]['vCPU']);
            // console.log(data[i]['Memory']);
            // console.log(data[i]['Instance Type']);
            // console.log(data[i]['PricePerUnit']);
            // console.log(data[i]['TermType']);
            // console.log(data[i]['Operating System']);
            // console.log();
            // console.log();
            count++;
        }
    }

    console.log(resultArray.length);
    exportResults(data, resultArray);
}

function ParseData(c: string, callBack: any) {
    Papa.parse(c, {
        header: true,
        skipEmptyLines: true,
        delimiter: ",",
        worker: false,
        beforeFirstChunk: function (chunk: any) {
            var rows = chunk.split(/\r\n|\r|\n/);
            rows.splice(0, 5);
            return rows.join("\r\n")
        },
        complete: function (results: any) {
            callBack(results.data);
            d = results.data;
        }
    });
}

calculateRequirements(program.cpu, program.ram, program.number, program.reservedRam, program.reservedCpu);

var Papa = require('papaparse');
const c = fs.readFileSync('C:\\Users\\alex.massey\\Downloads\\index.csv', 'utf8');

ParseData(c, ProcessResults);


