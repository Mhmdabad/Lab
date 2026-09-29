import { Controller, Module } from '@nestjs/common';
import { testController,UsersController } from './users.controller';
import { UsersService } from './users.service';


@Module({
    controllers: [testController,UsersController],
    providers: [UsersService]

})
export class UsersModule {}