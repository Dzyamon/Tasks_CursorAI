function addRow(button) {
    const currentRow = button.parentElement.parentElement;
    const newRow = document.createElement('tr');
    newRow.innerHTML = `
        <td><input type="text" class="category" placeholder="Enter category"></td>
        <td><input type="number" class="amount" placeholder="Enter amount"></td>
        <td>
            <button onclick="addRow(this)">Add</button>
            <button onclick="this.parentElement.parentElement.remove()">Remove</button>
        </td>
    `;
    currentRow.parentNode.insertBefore(newRow, currentRow.nextSibling);
}

function calculateExpenses() {
    const rows = document.querySelectorAll('#expenseTable tbody tr');
    const expenses = [];
    let total = 0;

    rows.forEach(row => {
        const category = row.querySelector('.category').value;
        const amount = parseFloat(row.querySelector('.amount').value) || 0;
        if (category && amount > 0) {
            expenses.push({ category, amount });
            total += amount;
        }
    });

    // Sort expenses by amount in descending order
    expenses.sort((a, b) => b.amount - a.amount);

    // Update results
    document.getElementById('total').textContent = total.toLocaleString();
    document.getElementById('dailyAverage').textContent = (total / 30).toLocaleString(undefined, {maximumFractionDigits: 2});

    const topExpensesList = document.getElementById('topExpenses');
    topExpensesList.innerHTML = '';
    
    // Display top 3 expenses
    expenses.slice(0, 3).forEach(expense => {
        const li = document.createElement('li');
        li.textContent = `${expense.category}: $${expense.amount.toLocaleString()}`;
        topExpensesList.appendChild(li);
    });
} 