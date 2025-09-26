/// UI Text Constants - All user-facing text strings
class UITextConstants {
  // ================================ NAVIGATION LABELS ================================
  static const String dashboard = 'Dashboard';
  static const String bills = 'Bills';
  static const String orders = 'Orders';
  static const String inventory = 'Inventory';
  static const String production = 'Production';
  static const String administration = 'Admin';
  static const String vendors = 'Vendors';
  static const String customers = 'Customers';
  static const String cards = 'Cards';

  // ================================ BUTTON LABELS ================================
  // Action Buttons
  static const String signIn = 'Sign In';
  static const String register = 'Register';
  static const String registerStaff = 'Register Staff';
  static const String registerStaffMember = 'Register Staff Member';
  static const String createOrder = 'Create Order';
  static const String createJob = 'Create Job';
  static const String addInventory = 'Add Inventory';
  static const String addCards = 'Add Cards';
  static const String addCard = 'Add Card';
  static const String addVendor = 'Add Vendor';
  static const String manageVendors = 'Manage Vendors';
  static const String vendorDetails = 'Vendor Details';
  static const String createCard = 'Create Card';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String back = 'Back';
  static const String getCard = 'Get Card';
  static const String findSimilarCard = 'Find Similar Card';
  static const String searchCustomer = 'Search Customer';
  static const String createCustomer = 'Create Customer';
  static const String addOrderItem = 'Add Item';
  static const String reviewOrder = 'Review Order';
  static const String submitOrder = 'Submit Order';
  static const String viewInventory = 'View Inventory';
  static const String hideTable = 'Hide Table';
  static const String retry = 'Retry';
  static const String changeImage = 'Change Image';
  static const String remove = 'Remove';
  static const String create = 'Create';

  // ================================ FORM LABELS ================================
  // Login/Register Forms
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot password?';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String role = 'Role';

  // Card Form
  static const String costPrice = 'Cost Price';
  static const String sellPrice = 'Sell Price';
  static const String quantity = 'Quantity';
  static const String maxDiscount = 'Max Discount (₹)';
  static const String selectVendor = 'Select Vendor';
  static const String cardImage = 'Card Image';
  static const String cardDetails = 'Card Details';
  static const String cardInformation = 'Card Information';
  static const String barcodeScanner = 'Barcode Scanner';
  static const String statistics = 'Statistics';
  static const String customerName = 'Customer Name';
  static const String customerPhone = 'Customer Phone';
  static const String barcode = 'Barcode';
  static const String discountAmount = 'Discount Amount';
  static const String requiresBox = 'Requires Box';
  static const String requiresPrinting = 'Requires Printing';
  static const String boxType = 'Box Type';
  static const String boxCost = 'Box Cost';
  static const String printingCost = 'Printing Cost';
  static const String deliveryDate = 'Delivery Date';

  // ================================ FORM HINTS ================================
  static const String phoneHint = '98XXXXXX01';
  static const String nameHint = 'John Doe';
  static const String costPriceHint = 'Enter cost price';
  static const String sellPriceHint = 'Enter sell price';
  static const String quantityHint = 'Enter quantity';
  static const String maxDiscountHint = 'Enter max discount percentage';
  static const String chooseVendorHint = 'Choose a vendor';
  static const String searchVendorsHint = 'Search vendors...';
  static const String tapToUploadImage = 'Tap to upload image';
  static const String customerNameHint = 'Enter customer name';
  static const String customerPhoneHint = 'Enter phone number';
  static const String barcodeHint = 'Enter barcode';
  static const String discountAmountHint = 'Enter discount amount';
  static const String boxCostHint = 'Enter box cost';
  static const String printingCostHint = 'Enter printing cost';

  // ================================ VALIDATION MESSAGES ================================
  // Login/Register Validation
  static const String pleaseEnterPhone = 'Please enter your phone number';
  static const String pleaseEnterValidPhone = 'Please enter a valid phone number';
  static const String pleaseEnterPassword = 'Please enter your password';
  static const String pleaseEnterConfirmPassword = 'Please confirm the password';
  static const String passwordTooShort = 'Password must be at least 3 characters';
  static const String passwordTooShortRegister = 'Password must be at least 8 characters';
  static const String passwordComplexity = 'Password must contain uppercase, lowercase, and number';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String pleaseEnterFullName = 'Please enter the full name';
  static const String nameTooShort = 'Name must be at least 2 characters';

  // Card Form Validation
  static const String pleaseEnterCostPrice = 'Please enter cost price';
  static const String pleaseEnterValidNumber = 'Please enter a valid number';
  static const String pleaseEnterSellPrice = 'Please enter sell price';
  static const String pleaseEnterQuantity = 'Please enter quantity';
  static const String pleaseEnterMaxDiscount = 'Please enter max discount';
  static const String discountRange = 'Discount must be between 0 and 100';
  static const String pleaseSelectVendor = 'Please select a vendor';
  static const String pleaseEnterCustomerName = 'Please enter customer name';
  static const String pleaseEnterCustomerPhone = 'Please enter customer phone';
  static const String pleaseEnterBarcode = 'Please enter barcode';
  static const String pleaseEnterDiscountAmount = 'Please enter discount amount';
  static const String pleaseEnterValidDiscount = 'Please enter a valid discount amount';
  static const String pleaseEnterValidQuantity = 'Please enter a valid quantity';
  static const String quantityExceedsStock = 'Quantity exceeds available stock';
  static const String pleaseSelectDeliveryDate = 'Please select delivery date';

  // ================================ PAGE TITLES ================================
  static const String appName = 'Vijay Shaadi Card';
  static const String loginTitle = 'Login';
  static const String signInTitle = 'Sign in to your account';
  static const String registerTitle = 'Register New Staff';
  static const String registerSubtitle = 'Add a new staff member to the system';
  static const String createCardTitle = 'Create New Card';
  static const String createCardSubtitle = 'Add a new card to the inventory system';
  static const String inventoryManagementTitle = 'Inventory Management';
  static const String inventoryManagementSubtitle = 'Manage your inventory items and cards';
  static const String createOrderCustomerSearchTitle = 'Create Order - Customer Search';
  static const String customerSearchSubtitle = 'Find or create a customer for the order';
  static const String orderCreationTitle = 'Create Order';
  static const String orderCreationSubtitle = 'Add items to the order';
  static const String orderReviewTitle = 'Review Order';
  static const String orderReviewSubtitle = 'Review and submit the order';

  // ================================ DIALOG TITLES ================================
  static const String selectImageTitle = 'Select Image';
  static const String galleryTitle = 'Gallery';
  static const String cameraTitle = 'Camera';

  // ================================ STATUS MESSAGES ================================
  static const String noVendorsAvailable = 'No vendors available';
  static const String customerNotFound = 'Customer not found';
  static const String customerCreatedSuccessfully = 'Customer created successfully';
  static const String customerFoundSuccess = 'Customer found successfully!';
  static const String customerCreateFailed = 'Failed to create customer.';
  static const String customerRetrieveFailed = 'Failed to retrieve created customer.';
  static const String customerNotFoundWithSuggestion = 'Customer not found. You can create a new customer by clicking "Create Customer".';
  static const String cardNotFound = 'Card not found';
  static const String orderCreatedSuccessfully = 'Order created successfully';
  static const String noOrderItems = 'No items added to order';
  static const String addInventoryComingSoon = 'Add Inventory feature coming soon!';
  static const String createProductionJobComingSoon = 'Create Production Job feature coming soon!';
  static const String getCardComingSoon = 'Get Card feature coming soon!';
  static const String findSimilarCardComingSoon = 'Find Similar Card feature coming soon!';

  // ================================ SUCCESS MESSAGES ================================
  static const String registrationSuccessful = 'Registration successful';

  // ================================ STATISTICS LABELS ================================
  static const String totalOrders = 'Total Orders';
  static const String pendingOrders = 'Pending Orders';
  static const String productionJobs = 'Production Jobs';
  static const String lowStockItems = 'Low Stock Items';
  static const String totalRevenue = 'Total Revenue';
  static const String activePartners = 'Active Partners';
  static const String todaysOrders = 'Today\'s Orders';
  static const String outOfStock = 'Out of Stock';
  static const String pendingPrintingJobs = 'Pending Printing Jobs';
  static const String pendingBoxJobs = 'Pending Box Jobs';
  static const String monthlyGrowth = 'Monthly Growth';
  static const String pendingBills = 'Pending Bills';
  static const String expenseLogging = 'Expense Logging';

  // ================================ STATISTICS SUBTITLES ================================
  // static const String ordersFromLastMonth = '+12% from last month';
  static const String ordersRequireAttention = 'Few require attention';
  static const String jobsInProgress = 'Jobs in progress';
  static const String needReorder = 'Need reorder';
  static const String revenueFromLastMonth = '+8% from last month';
  static const String newPartnersThisMonth = '3 new this month';
  static const String ordersCreatedToday = 'Orders created today';
  static const String itemsNeedRestocking = 'Items need restocking';
  static const String jobsInPrintingQueue = 'Jobs in printing queue';
  static const String boxOrdersInQueue = 'Box orders in queue';
  static const String orderGrowthThisMonth = 'Order growth this month';
  static const String billsAwaitingPayment = 'Bills awaiting payment';
  static const String ordersPendingExpenseLogging = 'Orders pending expense logging';

  // ================================ WELCOME MESSAGES ================================
  static const String welcomeBack = 'Welcome back!';
  static const String welcomeSubtitle = 'Here\'s what\'s happening with your {role} operations';

  // ================================ QUICK ACTIONS ================================
  static const String quickActions = 'Quick Actions';

  // ================================ MOCK DATA (removed unused) ================================
}
