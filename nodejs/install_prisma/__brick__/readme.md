
https://www.youtube.com/watch?v=RebA5J-rlwg&list=LL&index=2&t=182s

>> npm i --save-dev prisma typescript ts-node @types/node nodemon
>> npx tsc --init
>> npx prisma init --datasource-provider postgresql

add model in schema.prisma
model User{
  id Int @id @default(autoincrement())
  name String
}
>> npx prisma migrate dev --name init
init is the name

>> npm i @prisma/client
>> npx prisma generate