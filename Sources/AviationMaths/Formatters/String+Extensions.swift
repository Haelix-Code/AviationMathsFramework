import MGRS
import Foundation

extension String {
    public var isValidMGRS: Bool {
        let mgrsNoSpaces = self.replacingOccurrences(of: " ", with: "")

        let mgrsPattern = "^(\\d{1,2})([C-HJ-NP-X])(?:([A-HJ-NP-Z][A-HJ-NP-V])((\\d{2}){0,5}))?$"
        guard let mgrsExpression = try? NSRegularExpression(
            pattern: mgrsPattern,
            options: .caseInsensitive)
        else { return false }

        let matches = mgrsExpression.matches(in: mgrsNoSpaces, range: NSRange(location: 0, length: mgrsNoSpaces.count))
        guard let match = matches.first else { return false }

        let mgrsString = mgrsNoSpaces as NSString

        let zone = Int(mgrsString.substring(with: match.range(at: 1)))!
        let band = mgrsString.substring(with: match.range(at: 2)).uppercased().first!

        guard GridZones.gridZone(zone, band) != nil else { return false }
        return true
    }
}
