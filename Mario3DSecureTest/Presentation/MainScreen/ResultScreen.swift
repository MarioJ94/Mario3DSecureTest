import SwiftUI

struct ResultScreen: View {
    let isSuccess: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(isSuccess ? .green : .red)

            Text(isSuccess ? "Success!" : "Failure")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(isSuccess ? .green : .red)

            Text(isSuccess
                 ? "Your payment was processed successfully."
                 : "Something went wrong. Please try again.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
