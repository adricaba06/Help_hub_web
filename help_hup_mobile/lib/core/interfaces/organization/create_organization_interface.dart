import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';

abstract class CreateOrganizationInterface {
  Future<Organization> createOrganization(CreateOrganizationRequest org);
}
