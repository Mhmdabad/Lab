import express from 'express'

const app=express()

app.use(express.json())

app.get("/aa/:year",(req,res)=>{
    const {name,age}=req.body
    const {year}=req.params
    const {grade}=req.query
    return res.json({"name":name, "age":age, "year":year, "grade":grade})
})
app.listen(3000,()=>{
    console.log("server is running on 3000")
})