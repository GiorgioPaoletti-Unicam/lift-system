# System Verification Lab 2122 - APP V - A.Y. 2021/2022

This repository contains the project developed by Giorgio Paoletti (Matriculation Number 119927), which aims at developing and verifying a model of a Lift System. This system is modeled using processes that communicate via a channel system composed of request and reply channels. The system consists of various components, each represented as a process, such as Button, Door, Cabin, and Controller.

## 📃 Project Structure

The project consists of several components, each modeled as a separate process:

1. **Button:** The Button process non-deterministically generates a floor request.
2. **Door:** The Door process manages the opening and closing of the elevator doors upon receiving commands from the Controller process.
3. **Cabin:** The Cabin process receives direction commands from the Controller process and moves accordingly.
4. **Controller:** This is the main process which manages the requests from all instances of the Button process and sends commands to the Cabin and Door processes.

Each process is represented by a do loop that manages various events and responses. The code is developed in Promela, and the corresponding automata are generated using JSpin.

## 📝 Verification

The system is verified by defining some Linear Temporal Logic (LTL) properties and formalizing them using remote references, which are used to refer to control points in correctness specifications. The properties defined are:

1. Whenever the door is open, the cabin must be standing.
2. Whenever the cabin is moving, the door must be closed.
3. A button cannot remain pressed forever.
4. The door cannot remain open forever.
5. The door cannot remain closed forever.
6. Whenever the button at floor x (x = 1, 2, 3) becomes pressed then the cabin will eventually be at floor x with the door open.
7. When no button is pressed and a button at floor x (x = 1, 2, 3) is pressed and then a button at floor y (y != x and y = 1, 2, 3) is pressed (no other button is pressed meanwhile), then the cabin will stand at floor x with the door open, and afterwards the cabin will stand at floor y with the door open (meanwhile, the cabin will not stand at any other floor different from y with the door open).

These properties have been verified using Spin, and the results are included in this repository.

## ⚙️ How to Run

Detailed instructions on how to run the system and verify the properties are available in the respective source code files.

## ✉️ Contact

For any questions or clarifications regarding this project, please contact Giorgio Paoletti at [email].

## ⚖️ License

This project is licensed under the MIT License. See the `LICENSE` file for details.
