import { IsString, IsNotEmpty, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

export class Random1BodyDto {
  @IsString()
  @IsNotEmpty()
  id!: string;

  @Type(() => Number)
  @IsInt()
  year!: number;
}