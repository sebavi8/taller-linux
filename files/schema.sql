CREATE DATABASE birthdays CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'birthdayapp'@'10.%' IDENTIFIED BY 'Cumples2026!';
GRANT ALL PRIVILEGES ON birthdays.* TO 'birthdayapp'@'10.%';
FLUSH PRIVILEGES;

USE birthdays;

CREATE TABLE people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(100),
    city VARCHAR(50)
);

INSERT INTO people (first_name, last_name, birth_date, email, city) VALUES
('Ana', 'Pérez', '1998-04-10', 'ana.perez@example.com', 'Montevideo'),
('Luis', 'Gómez', '2001-07-15', 'luis.gomez@example.com', 'Canelones'),
('María', 'Rodríguez', '1995-04-10', 'maria.rodriguez@example.com', 'Maldonado'),
('Jorge', 'Silva', '1992-11-21', 'jorge.silva@example.com', 'Florida'),
('Lucía', 'Fernández', '2000-03-08', 'lucia.fernandez@example.com', 'Colonia');
