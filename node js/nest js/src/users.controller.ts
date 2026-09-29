import { Controller, Get ,Param, Query,Body,Post} from '@nestjs/common';
import {Random1BodyDto} from "./dto/random1-body-dto"
import { UsersService } from './users.service';

@Controller("test")
export class testController{
    @Post(":id/:year")
    random(
        @Param() random1:Random1BodyDto,
        @Query() random2:{sort:string;limit:number},
        @Body() random3:{name:string;age:number}
    ){
        return [random1.id]
    }
    
}

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  getUsers() {
    return this.usersService.getUsers();
  }
}