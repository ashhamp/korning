# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"
require 'pry'
# binding.pry

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

def employees
  employees = []
  CSV.foreach('sales.csv', headers: true) do |row|
    employees << row['employee']
  end

  employees.uniq
end

def import_employees
    db_connection do |conn|
      employees.each do |employee|

      name = employee.split("(").first.strip
      email = employee.split("(")[1].chop
      begin
        conn.exec("INSERT INTO employees (name, email) VALUES ($1, $2)", [name, email])
      rescue PG::UniqueViolation
        puts "Duplicate entry. Skipping #{name}, #{email}."
      end
    end
  end
end

def employee_id(employee_name)
  employee_id = nil
  id = db_connection do |conn|
    conn.exec("SELECT * FROM employees WHERE name = '#{employee_name}'");
  end

  employee_id = id.first['id']
  employee_id
end

def customers
  customers = []
  CSV.foreach('sales.csv', headers: true) do |row|
    customers << row['customer_and_account_no']
  end

  customers.uniq
end

def import_customers
  db_connection do |conn|
    customers.each do |customer|

      name = customer.split("(").first.strip
      account_number = customer.split("(")[1].chop
      begin
        conn.exec("INSERT INTO customers (name, account_number) VALUES ($1, $2)", [name, account_number])
      rescue PG::UniqueViolation
        puts "Duplicate entry. Skipping, #{name}, #{account_number}."
      end
    end
  end
end

def customer_id(customer_name)
  customer_id = nil
  id = db_connection do |conn|
    conn.exec("SELECT * FROM customers WHERE name = '#{customer_name}'");
  end

  customer_id = id.first['id']
  customer_id
end

def products
  products = []
  CSV.foreach('sales.csv', headers: true) do |row|
    products << row['product_name']
  end

  products.uniq
end


def import_products
  db_connection do |conn|
    products.each do |product|

      name = product

      begin
        conn.exec("INSERT INTO products (name) VALUES ($1)", [name])
      rescue PG::UniqueViolation
        puts "Duplicate entry. Skipping, #{name}."
      end
    end
  end
end

def product_id(product_name)
    product_id = nil
    id = db_connection do |conn|
      conn.exec("SELECT * FROM products WHERE name = '#{product_name}'");
    end

    product_id = id.first['id']
    product_id
end

def frequencies

  frequencies = []
  CSV.foreach('sales.csv', headers: true) do |row|
    frequencies << row['invoice_frequency']
  end

  frequencies.uniq
end

def import_invoice_frequencies
  db_connection do |conn|
    frequencies.each do |frequency|

      name = frequency

      begin
        conn.exec("INSERT INTO invoice_frequency (name) VALUES ($1)", [name])
      rescue PG::UniqueViolation
        puts "Duplicate entry. Skipping, #{name}."
      end
    end
  end
end

def invoice_frequency_id(frequency)
    invoice_frequency_id = nil
    id = db_connection do |conn|
      conn.exec("SELECT * FROM invoice_frequency WHERE name = '#{frequency}'");
    end

    invoice_frequency_id = id.first['id']
    invoice_frequency_id
end


def import_transactions
  db_connection do |conn|
    CSV.foreach('sales.csv', headers: true) do |row|

      employee = row['employee'].split("(").first.strip
      customer = row['customer_and_account_no'].split("(").first.strip
      product = row['product_name']
      invoice_frequency = row['invoice_frequency']
      sale_date = row['sale_date']
      sale_amount = row['sale_amount']
      units_sold = row['units_sold']
      invoice_number = row['invoice_no']

      begin
        conn.exec("INSERT INTO transactions (sale_date, sale_amount, units_sold, invoice_number, invoice_frequency_id, product_id, employee_id, customer_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", [sale_date, sale_amount, units_sold, invoice_number, "#{invoice_frequency_id(invoice_frequency)}", "#{product_id(product)}", "#{employee_id(employee)}", "#{customer_id(customer)}"])
      rescue PG::UniqueViolation
        puts "Duplicate entry. Skipping, #{sale_date}, #{sale_amount}, #{units_sold}, #{invoice_number}, #{invoice_frequency_id(invoice_frequency)}, #{product_id(product)}, #{employee_id(employee)}, #{customer_id(customer)}."
      end
    end
  end
end

import_employees
import_customers
import_products
import_invoice_frequencies
import_transactions
