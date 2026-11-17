-- PostgreSQL Schema generated from Prisma Schema

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS "User_Stock" CASCADE;
DROP TABLE IF EXISTS "Stock" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

-- CreateTable: Stock
CREATE TABLE "Stock" (
    "id" SERIAL NOT NULL,
    "ticker" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "price" DECIMAL(65,30) NOT NULL,
    "last_price_date" TIMESTAMP(3) NOT NULL,
    "market_cap" DECIMAL(65,30) NOT NULL,
    "price_to_sales" DECIMAL(65,30) NOT NULL,
    "year" TIMESTAMP(3) NOT NULL,
    "quarter" TIMESTAMP(3) NOT NULL,
    "gross_margin" DECIMAL(65,30) NOT NULL,
    "operating_margin" DECIMAL(65,30) NOT NULL,
    "return_on_assets" DECIMAL(65,30) NOT NULL,
    "return_on_equity" DECIMAL(65,30) NOT NULL,
    "revenue" DECIMAL(65,30) NOT NULL,
    "ebitda" DECIMAL(65,30) NOT NULL,
    "pat" DECIMAL(65,30) NOT NULL,
    "total_cash" DECIMAL(65,30) NOT NULL,
    "total_debt" DECIMAL(65,30) NOT NULL,
    "debt_to_equity" DECIMAL(65,30) NOT NULL,
    "current_ratio" DECIMAL(65,30) NOT NULL,

    CONSTRAINT "Stock_pkey" PRIMARY KEY ("id")
);

-- CreateTable: User
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable: User_Stock (Junction Table)
CREATE TABLE "User_Stock" (
    "userId" INTEGER NOT NULL,
    "stockId" INTEGER NOT NULL,

    CONSTRAINT "User_Stock_pkey" PRIMARY KEY ("userId","stockId")
);

-- CreateIndex
CREATE UNIQUE INDEX "Stock_ticker_key" ON "Stock"("ticker");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "User_Stock" ADD CONSTRAINT "User_Stock_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User_Stock" ADD CONSTRAINT "User_Stock_stockId_fkey" FOREIGN KEY ("stockId") REFERENCES "Stock"("id") ON DELETE CASCADE ON UPDATE CASCADE;
