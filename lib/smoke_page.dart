import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'smoke_cubit.dart';
import 'widgets/form_widgets.dart';

class SmokePage extends StatefulWidget {
  const SmokePage({super.key});

  @override
  State<SmokePage> createState() => _SmokePageState();
}

class _SmokePageState extends State<SmokePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<SmokeCubit>().loadSmokingEffects(AppLocalizations.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.appBarTitle, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey,
      ),
      body: BlocConsumer<SmokeCubit, SmokeState>(
        listenWhen: (previous, current) => previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.formSubmitted) {
            return _buildFormSubmitted(context);
          }
          
          return _buildForm(context, state);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, SmokeState state) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.doYouSmokeQuestion,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => context.read<SmokeCubit>().setSmoker(true),
                  label: Text(l10n.yes),
                  backgroundColor: state.isSmoker == true ? Colors.green.shade800 : Colors.green,
                ),
                const SizedBox(width: 30),
                FloatingActionButton.extended(
                  onPressed: () => context.read<SmokeCubit>().setSmoker(false),
                  label: Text(l10n.no),
                  backgroundColor: state.isSmoker == false ? Colors.red.shade800 : Colors.red,
                ),
              ],
            ),
            
            if (state.isSmoker == true) _buildSmokerSection(context, state),
            
            if (state.isSmoker == false) _buildNonSmokerSection(context, state),
            
            if (state.showCommentsInput) ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              
              Text(
                state.isSmoker == true && state.hasHealthIssues == true ? 
                  l10n.whyNotQuitSmoking : 
                  state.isSmoker == true ? 
                    l10n.whyNotQuitSmoking : 
                    l10n.commentsAboutSmokers,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: state.getCommentsHintText(l10n),
                ),
                onChanged: (value) => context.read<SmokeCubit>().setComments(value),
                controller: TextEditingController(text: state.comments)..selection = 
                  TextSelection.fromPosition(TextPosition(offset: state.comments?.length ?? 0)),
              ),
            ],
            
            if (state.isFormComplete) ...[
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: state.isLoading ? null : () => context.read<SmokeCubit>().submitForm(l10n),
                  child: state.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.submit),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSmokerSection(BuildContext context, SmokeState state) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 20),
        
        Text(
          l10n.cigarettesPerDay,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildSlider(
          value: (state.cigarettesPerDay ?? 0).toDouble(),
          min: 0.0,
          max: 60.0,
          onChanged: (value) => context.read<SmokeCubit>().setCigarettesPerDay(value.round()),
          l10n: l10n,
        ),
        
        const SizedBox(height: 30),
        
        Text(
          l10n.yearsSmokingQuestion,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildSlider(
          value: (state.yearsSmoked ?? 0).toDouble(),
          min: 0.0,
          max: 60.0,
          onChanged: (value) => context.read<SmokeCubit>().setYearsSmoked(value.round()),
          l10n: l10n,
        ),
        
        const SizedBox(height: 30),
        
        Text(
          l10n.healthIssuesQuestion,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildBooleanRadioGroup(
          value: state.hasHealthIssues,
          onChanged: (value) => context.read<SmokeCubit>().setHasHealthIssues(value!),
          l10n: l10n,
        ),
        
        if (state.hasHealthIssues == true) ...[
          const SizedBox(height: 30),
          Text(
            l10n.wantToQuitQuestion,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildBooleanRadioGroup(
            value: state.wantsToQuit,
            onChanged: (value) => context.read<SmokeCubit>().setWantsToQuit(value!),
            l10n: l10n,
          ),
          
          if (state.wantsToQuit == true) ...[
            const SizedBox(height: 30),
            Text(
              l10n.quitDatePlanned,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FormWidgets.buildDatePicker(
              context: context,
              selectedDate: state.quitDate,
              onDateSelected: (date) => context.read<SmokeCubit>().setQuitDate(date),
              l10n: l10n,
            ),
          ],
        ],
        
        if (state.hasHealthIssues == false) ...[
          const SizedBox(height: 30),
          Text(
            l10n.awarenessOfEffects,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildAwarenessRadioGroup(
            value: state.awarenessOfEffects,
            onChanged: (value) => context.read<SmokeCubit>().setAwarenessOfEffects(value!),
            l10n: l10n,
          ),
          
          if (state.awarenessOfEffects == false) ...[
            const SizedBox(height: 20),
            Text(
              l10n.smokingEffects,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FormWidgets.buildSmokingEffectsList(state.smokingEffects, state.error),
          ],
        ],
      ],
    );
  }
  
  Widget _buildNonSmokerSection(BuildContext context, SmokeState state) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 20),
        
        Text(
          l10n.awarenessOfEffects,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FormWidgets.buildAwarenessRadioGroup(
          value: state.awarenessOfEffects,
          onChanged: (value) => context.read<SmokeCubit>().setAwarenessOfEffects(value!),
          l10n: l10n,
        ),
        
        if (state.awarenessOfEffects == false) ...[
          const SizedBox(height: 20),
          Text(
            l10n.smokingEffects,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FormWidgets.buildSmokingEffectsList(state.smokingEffects, state.error),
        ],
      ],
    );
  }
  
  Widget _buildFormSubmitted(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          Text(
            l10n.formSubmitted,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.thankYouForFillingForm,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () => context.read<SmokeCubit>().resetForm(l10n),
            child: Text(l10n.fillAgain),
          ),
        ],
      ),
    );
  }
}