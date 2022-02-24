### Tienda-sql

This database supports a typical shopping cart to buy products from different categories.

There are 3 types of users:

Administrator: Who has the access to manage users and providers, the latter can be approved or banned by administrators. Admins also have the possibility to see sales reports, unfinished sales, payment methods and other info from the orders created, including all possible records between multiple products and their purchase orders.

Provider: Who has the access to create products and modify their stock.

User (customer): Who access the app to purchase items, and has to provide all the required information to do so.

This data model will allow the application to show the list of available products, possibly using filters, so they can be selected by each customer individually and put into the shopping cart. After completing their selection, users will then access the checkout in which they enter their payment method and all relevant contact information, and proceed to confirm the order, which can include one or multiple products. 

Users can sign in using their email and password as soon as their account is created, whilst providers must be approved by the administrators. 

Users will be able to find their ongoing orders, and the status for each individual product included after purchase, considering that an order is related to only one user.

Participants:

Luis Gómez

Andrés Castillo

Brian Dávalos
