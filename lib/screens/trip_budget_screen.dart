import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'all_expenses_screen.dart'; // ✅ VITAL: Ensure this import exists

class TripBudgetScreen extends StatelessWidget {
  final String tripId;
  const TripBudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    
    return StreamBuilder<Trip?>(
      stream: databaseService.getTrip(tripId),
      builder: (context, tripSnapshot) {
        if (!tripSnapshot.hasData || tripSnapshot.data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          );
        }
        
        final trip = tripSnapshot.data!;
        
        return StreamBuilder<List<Expense>>(
          stream: databaseService.getExpenses(tripId),
          builder: (context, expensesSnapshot) {
            final expenses = expensesSnapshot.data ?? [];
            
            // Calculate totals
            final totalBudget = trip.budget;
            final totalSpent = expenses.fold<double>(
              0.0,
              (sum, expense) => sum + expense.amount,
            );
            final remaining = totalBudget - totalSpent;
            final percentageLeft = totalBudget > 0
                ? (remaining / totalBudget * 100).round()
                : 0;

            // Get only the 5 most recent expenses for the preview list
            final recentExpenses = expenses.take(5).toList();

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- BUDGET SUMMARY CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.blueGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Remaining Budget',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${remaining.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$percentageLeft% left of \$${totalBudget.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Total Budget', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text('\$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
                                ),
                                Container(height: 30, width: 1, color: Colors.white24),
                                Column(
                                  children: [
                                    const Text('Total Spent', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text('\$${totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // --- RECENT EXPENSES HEADER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Expenses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              print("See all clicked! Navigating to AllExpensesScreen...");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllExpensesScreen(tripId: tripId),
                                ),
                              );
                            }, 
                            child: const Text('See all', style: TextStyle(color: AppTheme.primaryBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // --- RECENT EXPENSES LIST ---
                      if (expenses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.receipt_long, size: 40, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No expenses yet',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the button below to add your first expense',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      else
                        ...recentExpenses.map((expense) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpenseCard(
                            expense: expense,
                            onTap: () {},
                            onDelete: () async {
                              final success = await databaseService.deleteExpense(expense.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Expense deleted'), backgroundColor: Colors.red),
                                );
                              }
                            },
                          ),
                        )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'add_expense_fab',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(tripId: tripId),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryBlue,
                elevation: 4,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Expense',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        );
      },
    );
  }
}