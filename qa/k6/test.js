//k6 run --vus 5 --iterations 20 test.js
import http from 'k6/http';

// export const options = {
//   vus: 10,
//   duration: '5s',
// };

export default function () {
  const payload=JSON.stringify({
    "username":"emilys",
    "password":"emilyspass"
  })
  const params = {
    headers: {
      'Content-Type': 'application/json'
    }
  };
 const response= http.post('https://dummyjson.com/auth/login',payload,params);
  console.log(response.body)
}