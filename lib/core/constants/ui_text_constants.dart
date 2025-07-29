/// UI Text Constants - All user-facing text strings
class UITextConstants {
  // ================================ NAVIGATION LABELS ================================
  static const String dashboard = 'Dashboard';
  static const String orders = 'Orders';
  static const String inventory = 'Inventory';
  static const String production = 'Production';
  static const String administration = 'Administration';
  static const String vendors = 'Vendors';
  static const String customers = 'Customers';

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
  static const String createCard = 'Create Card';
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
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String role = 'Role';

  // Card Form
  static const String costPrice = 'Cost Price';
  static const String sellPrice = 'Sell Price';
  static const String quantity = 'Quantity';
  static const String maxDiscount = 'Max Discount (%)';
  static const String selectVendor = 'Select Vendor';
  static const String cardImage = 'Card Image';
  static const String cardDetails = 'Card Details';
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
  static const String phoneHint = '9876543210';
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
  static const String passwordTooShort = 'Password must be at least 6 characters';
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
  static const String signInTitle = 'Sign in to your account';
  static const String registerTitle = 'Register New Staff';
  static const String registerSubtitle = 'Add a new staff member to the system';
  static const String createCardTitle = 'Create New Card';
  static const String createCardSubtitle = 'Add a new card to the inventory system';
  static const String inventoryManagementTitle = 'Inventory Management';
  static const String inventoryManagementSubtitle = 'Manage your inventory items and cards';
  static const String customerSearchTitle = 'Customer Search';
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

  // ================================ STATISTICS SUBTITLES ================================
  static const String ordersFromLastMonth = '+12% from last month';
  static const String ordersRequireAttention = '5 require attention';
  static const String jobsInProgress = '3 in progress';
  static const String needReorder = 'Need reorder';
  static const String revenueFromLastMonth = '+8% from last month';
  static const String newPartnersThisMonth = '3 new this month';

  // ================================ WELCOME MESSAGES ================================
  static const String welcomeBack = 'Welcome back!';
  static const String welcomeSubtitle = 'Here\'s what\'s happening with your {role} operations';

  // ================================ QUICK ACTIONS ================================
  static const String quickActions = 'Quick Actions';

  // ================================ MOCK DATA ================================
  // Order Statuses
  static const String statusPending = 'Pending';
  static const String statusInProduction = 'In Production';
  static const String statusCompleted = 'Completed';
  static const String statusAll = 'All';

  // Categories
  static const String categoryAll = 'All';
  static const String categoryBusinessCards = 'Business Cards';
  static const String categoryFlyers = 'Flyers';
  static const String categoryBrochures = 'Brochures';

  // ================================ AUDIT LOG ACTIONS ================================
  static const String auditOrderCreated = 'Order Created';
  static const String auditStockUpdated = 'Stock Updated';

  // ================================ STAFF ROLES ================================
  static const String roleAdmin = 'Admin';
  static const String roleManager = 'Manager';
  static const String roleSales = 'Sales';
  static const String roleProduction = 'Production';

  // ================================ INVENTORY ITEMS ================================
  static const String businessCardPremium = 'Business Card Premium';
  static const String flyerGlossyA4 = 'Flyer Glossy A4';
  static const String brochureTriFold = 'Brochure Tri-Fold';

  // ================================ VENDORS ================================
  static const String premiumPaperCo = 'Premium Paper Co.';
  static const String qualityPrintSupplies = 'Quality Print Supplies';

  // ================================ CUSTOMERS ================================
  static const String johnDoe = 'John Doe';
  static const String janeSmith = 'Jane Smith';
  static const String bobJohnson = 'Bob Johnson';

  // ================================ STAFF MEMBERS ================================
  static const String johnAdmin = 'John Admin';
  static const String sarahManager = 'Sarah Manager';

  // ================================ AUDIT LOG DETAILS ================================
  static const String auditOrderCreatedDetails = 'Created order ORD-001 for John Doe';
  static const String auditStockUpdatedDetails = 'Updated stock for CARD-001: +500 units';

  // ================================ IP ADDRESSES ================================
  static const String ipAddress1 = '192.168.1.100';
  static const String ipAddress2 = '192.168.1.101';
}
